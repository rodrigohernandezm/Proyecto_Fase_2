library(readxl)

ruta<- "C:/Users/rodri/OneDrive/Documentos/Maestria/Cuarto_trimestre/Mineria de datos/Proyecto_Fase_2/datasets"

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




