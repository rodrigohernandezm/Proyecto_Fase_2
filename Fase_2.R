library(readxl)
library(stringi)
library(dplyr)
library(arules)
library(rpart)
library(rpart.plot)


#ruta<- "C:/Users/rodri/OneDrive/Documentos/Maestria/Cuarto_trimestre/Mineria de datos/Proyecto_Fase_2/datasets"
ruta<- "C:/Users/rhernandez/OneDrive - Generando Soluciones Anlalíticas S.A/Documents/New folder/Proyecto_Fase_2/datasets"

archivos<- list.files(path = ruta, pattern = "\\.xlsx$", full.names = TRUE)

for (archivo in archivos) {
  base<- basename(archivo)
  anio<- regmatches(base, regexpr("\\d{4}", base))
  name<- paste0("df_",anio)
  datos<- read_excel(archivo)
  assign(name, datos)
}


df_2018<- as.data.frame(df_2018)
df_2019<- as.data.frame(df_2019)
df_2020<- as.data.frame(df_2020)
df_2021<- as.data.frame(df_2021)
df_2022<- as.data.frame(df_2022)
df_2023<- as.data.frame(df_2023)
df_2024<- as.data.frame(df_2024)

anios <- 2020:2024

for (i in anios) {
  df <- get(paste0("df_", i))
  
  names(df) <- tolower(stri_trans_general(names(df), "Latin-ASCII"))
  
  df <- df %>%
    rename_with(~ gsub("gran_grupos|gran_grupos", "gran_grupos", .x)) %>%
    rename_with(~ gsub("subg_primarios|subg_principales", "subg_principales", .x)) %>%
    rename_with(~ gsub("g_primarios", "g_primarios", .x))
  
  df <- df %>% select(-any_of(c("edad_quinquenales", "ocupacionhabitual", "filter_$")))
  
  cols_a_texto <- c("area_geo_inf")
  for (col in cols_a_texto) {
    if (col %in% names(df)) {
      df[[col]] <- as.character(df[[col]])
    }
  }
  
  assign(paste0("df_", i), df)
}

df_final <- bind_rows(mget(paste0("df_", anios)))
df_final<- df_final[, setdiff(names(df_final), "num_corre")]
df_final$area_geo_inf<- as.numeric(df_final$area_geo_inf)


### arboles de decision
## medicion de entropia

library(entropy)

entropia_falta <- entropy(table(df_final$falta_inf), unit="log2")
entropia_falta


info_gain <- function(var, class) {
  total <- length(class)
  ent_total <- entropy(table(class), unit="log2")
  
  ent_cond <- 0
  for (v in unique(var)) {
    subset_class <- class[var == v]
    ent_v <- entropy(table(subset_class), unit="log2")
    ent_cond <- ent_cond + (length(subset_class) / total) * ent_v
  }
  
  return(ent_total - ent_cond)
}

vars <- c("sexo_inf", "edad_inf", "depto_boleta",
          "gran_grupos", "area_geo_inf", "grupo_etnico_inf", "falta_inf")

resultados <- sapply(vars, function(v) {
  info_gain(df_final[[v]], df_final$falta_inf)
})

sort(resultados, decreasing = TRUE)

####### arbol 1 predecir si es una falta contra las buenas costumbres #####

#df_a_1$falta_inf<- ifelse(df_final$falta_inf == 3, 1,0) #3 es falta contra las buenas constumbres, probar esto en otra pc
 
a_1 <- rpart(falta_inf ~ depto_boleta + muni_boleta + mes_boleta + ano_boleta + sexo_inf + edad_inf + 
               grupo_etnico_inf + est_conyugal_inf + nacimiento_inf + cond_alfabetismo_inf + niv_escolaridad_inf 
             + est_ebriedad_inf + area_geo_inf + depto_nacimiento_inf + subg_principales + gran_grupos + g_primarios
              ,data = df_final, method = "class")

rpart.plot(a_1, type = 2, extra=0, under = TRUE, fallen.leaves = TRUE, box.palette = "BuGn",
           main="Tipo de falta", cex = 0.5)
#caso1 (yo)
persona_a_1_1 <- data.frame(
  depto_boleta = 1,
  muni_boleta = 108,
  mes_boleta = 6,
  ano_boleta = 2023,
  sexo_inf = 1,                   
  edad_inf = 29,
  grupo_etnico_inf = 2,
  est_conyugal_inf = 1,
  nacimiento_inf = 1,             
  cond_alfabetismo_inf = 1,       
  niv_escolaridad_inf = 5,        
  est_ebriedad_inf = 1,          
  area_geo_inf = 1,               
  depto_nacimiento_inf = 1,
  subg_principales = 2141,
  gran_grupos = 21,
  g_primarios = 1
)

result <- predict(a_1, persona_a_1_1, type = "prob")
result<- max(as.numeric(unlist(result)))
result

## caso 2 
#Don José es un hombre de 65 años, vive en un área rural. Tiene bajo nivel educativo y un estado conyugal
#distinto, lo cual lo lleva a otro nodo del árbol. Se encontraba sobrio.

persona_a_1_2 <- data.frame(
  depto_boleta = 3,
  muni_boleta = 301,
  mes_boleta = 11,
  ano_boleta = 2021,
  sexo_inf = 1,
  edad_inf = 65,
  grupo_etnico_inf = 2,
  est_conyugal_inf = 8,
  nacimiento_inf = 501,
  cond_alfabetismo_inf = 1,
  niv_escolaridad_inf = 1,
  est_ebriedad_inf = 1,
  area_geo_inf = 2,
  depto_nacimiento_inf = 3,
  subg_principales = 120,
  gran_grupos = 10,
  g_primarios = 1)

result <- predict(a_1, persona_a_1_2, type = "prob")
result<- max(as.numeric(unlist(result)))
result


### tiene los mismos valores siendo perfiles totalmente diferentes, esto quiere decir que se complementa con el analisis de la fase 1
### como la mayoria de faltas son contra las buenas constumbres por eso es el valor predominante. 


####### arbol 2 predecir grupo etario#####

df_final<- df_final %>%
  mutate(
    edad_quinquenal = cut(
      edad_inf,
      breaks = seq(0, 100, by = 5),  
      labels = paste(seq(0, 95, by = 5), seq(4, 99, by = 5), sep = "-"),
      include.lowest = TRUE,
      right = TRUE
    )
  )

a_2 <- rpart(edad_quinquenal ~ depto_boleta 
             + mes_boleta 
             + falta_inf 
             + est_conyugal_inf
             + sexo_inf 
             + grupo_etnico_inf
             + cond_alfabetismo_inf
             + niv_escolaridad_inf 
             + est_ebriedad_inf 
             + area_geo_inf,
             data = df_final, method = "class")

rpart.plot(a_2, type = 2, extra=0, under = TRUE, fallen.leaves = TRUE, box.palette = "BuGn",
           main="grupo etario", cex = 0.5)

### predecir el nivel de escolaridad

a_3 <- rpart(niv_escolaridad_inf ~ depto_boleta
             + muni_boleta 
             + mes_boleta 
             + ano_boleta 
             + falta_inf 
             + sexo_inf 
             + grupo_etnico_inf
             + est_conyugal_inf 
             + nacimiento_inf 
             + edad_quinquenal
             + est_ebriedad_inf 
             + area_geo_inf 
   #          + depto_nacimiento_inf 
             + g_edad_60ymas
             + subg_principales
             + gran_grupos 
             + g_primarios,
             data = df_final, method = "class"
)

rpart.plot(a_3, type = 2, extra=0, under = TRUE, fallen.leaves = TRUE, box.palette = "BuGn",
           main="grupo etario", cex = 0.5)

## se va a quitar analfabetimos para que no este sesgado ya que hay relacion entre nivel educativo. nacionalidad tambien porque 
#la mayoria son guatemaltecos

nodos <- a_3$frame
impureza_promedio <- sum(nodos$dev) / sum(nodos$n)
impureza_promedio

library(entropy)

library(entropy)

library(entropy)

# Obtener nodos hoja
leaf_nodes <- row.names(a_3$frame)[a_3$frame$var == "<leaf>"]

# Extraer probabilidades 
entropias <- sapply(leaf_nodes, function(node) {
  probs <- a_3$frame$yprob[[node]]
  entropy(probs, unit = "log2")
})

entropias
mean(entropias)

bestcp <- a_3$cptable[which.min(a_3$cptable[,"xerror"]), "CP"]
a_3_podado <- prune(a_3, cp = bestcp)
a_3_podado

summary(a_3)
entropias
mean(entropias)


plot(a_3)
text(a_3, pretty = 0)

nrow(a_3$frame[a_3$frame$var == "<leaf>", ])

### prediccion del area 

a_4<- rpart(est_ebriedad_inf ~ depto_boleta
             + muni_boleta 
             + mes_boleta 
             + ano_boleta 
             + falta_inf 
             + sexo_inf 
             + niv_escolaridad_inf
             + grupo_etnico_inf
             + est_conyugal_inf 
             + nacimiento_inf 
             + edad_quinquenal
             + area_geo_inf 
             + g_edad_60ymas
             + subg_principales
             + gran_grupos 
             + g_primarios,
             data = df_final, method = "class"
)

rpart.plot(a_4, type = 2, extra=0, under = TRUE, fallen.leaves = TRUE, box.palette = "BuGn",
           main="grupo etario", cex = 0.5)

