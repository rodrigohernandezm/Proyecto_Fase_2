# 📊 Proyecto Fase 2 – Modelos Predictivos (Árboles, Random Forest y Redes Neuronales)

Esta fase lleva el proyecto de faltas judiciales un paso adelante: a partir del dataset integrado/limpio (2018–2024) se construyen modelos **supervisados** para predecir variables clave como tipo de falta, grupo etario, nivel educativo, área geográfica y año de la boleta. El flujo incluye:

- **R (`Fase_2.R`)**: árboles de decisión con `rpart` y ensambles **Random Forest** para distintos objetivos.
- **Python (`redes_neuronales.ipynb`)**: redes neuronales densas en TensorFlow/Keras para clasificación multiclase y binaria.

---

## 📁 Estructura del proyecto

```
/Proyecto_Fase_2/
├── Fase_2.R                   # Script principal en R (árboles de decisión y random forest)
├── redes_neuronales.ipynb     # Notebook en Python/TensorFlow para redes densas
├── datasets/                  # Archivos Excel consolidados por año
│   ├── faltas-judiciales-ano-2018.xlsx
│   ├── faltas-judiciales-ano-2019.xlsx
│   ├── faltas-judiciales-ano-2020.xlsx
│   ├── faltas-judiciales-ano-2021.xlsx
│   ├── faltas-judiciales-ano-2022.xlsx
│   ├── faltas-judiciales-2023.xlsx
│   └── base-faltas-judiciales-2024.xlsx
├── arbol_*.png                # Gráficas exportadas de los árboles de decisión
├── random_forest_*.png        # Gráficas e importancias de los bosques aleatorios
└── red_neuronal_*.png         # Curvas y matrices de las redes neuronales
```

---

## ⚙️ Requisitos de ejecución

### Datos
Coloque todos los Excel anuales dentro de `datasets/`. El código identifica el año a partir del nombre del archivo (`...2019.xlsx`, `...2024.xlsx`, etc.).

### Sistema operativo
Probado en **Windows, macOS y Linux**. Ajuste las rutas según su entorno.

### R (Fase_2.R)
- **Versión recomendada:** R ≥ 4.2.
- **IDE:** RStudio (sugerido) o terminal con `Rscript`.
- **Paquetes necesarios:**
  ```r
  install.packages(c(
    "readxl", "stringi", "dplyr", "arules", "rpart", "rpart.plot",
    "randomForest", "entropy"
  ))
  ```

### Python (notebook `redes_neuronales.ipynb`)
- **Versión recomendada:** Python 3.10 o 3.11.
- **Entorno:** Jupyter Notebook o VS Code con soporte para notebooks.
- **Dependencias principales:**
  ```bash
  python -m venv .venv
  source .venv/bin/activate   # Windows: .venv\Scripts\activate
  pip install numpy pandas tensorflow scikit-learn seaborn unidecode
  ```

---

## 📥 Clonar el repositorio

```bash
git clone https://github.com/rodrigohernandezm/Proyecto_Fase_2
cd Proyecto_Fase_2
```

---

## 🚀 Ejecución en R: Árboles de decisión y Random Forest

1. **Configurar la ruta de datos**  
   Abra `Fase_2.R` y ajuste `ruta <- ".../datasets"` para apuntar a su carpeta local (ejemplos: `"D:/Proyectos/Proyecto_Fase_2/datasets"` en Windows o `"/home/usuario/Proyecto_Fase_2/datasets"` en Linux/macOS).

2. **Carga e integración**  
   - Se leen todos los `.xlsx`, se extrae el año del nombre y se crean data frames `df_2018`–`df_2024`.
   - Se estandarizan nombres de columnas (minúsculas, sin acentos) y se homologa nomenclatura (`gran_grupos`, `subg_principales`, etc.).
   - Se descartan columnas inconsistentes (`edad_quinquenales`, `ocupacionhabitual`, `filter_$`) y se convierte `area_geo_inf` a numérico.  
   - Se consolidan los años 2020–2024 en `df_final`, eliminando `num_corre`.

3. **Árboles de decisión (`rpart`)**  
   - **Tipo de falta (`a_1`)**: predice `falta_inf` usando variables sociodemográficas y geográficas. Incluye ejemplos de predicción para perfiles sintéticos.  
   - **Grupo etario (`a_2`)**: clasifica en `edad_quinquenal` a partir de falta, año, sexo, alfabetismo, área, etc.  
   - **Escolaridad y año de boleta**: árboles adicionales sobre `niv_escolaridad_inf` y `ano_boleta` (ver secciones posteriores del script).  
   - Cada árbol se grafica con `rpart.plot` y puede exportarse (`arbol_1.png`, `arbol_2.png`, etc.).

4. **Random Forest (`randomForest`)**  
   - Modelos de ensamble para **tipo de falta**, **sexo** y **área geográfica (urbano/rural)**.  
   - Parámetros definidos en el script (p.ej., `ntree`, `mtry`) con `set.seed(42)` para reproducibilidad.  
   - Se generan métricas de exactitud, matrices de confusión e importancia de variables (exportadas a `random_forest_*.png`).

5. **Ejecución completa**  
   - Desde RStudio: *Source* (`Ctrl + Shift + Enter`).  
   - Desde terminal: `Rscript Fase_2.R`.

6. **Salidas esperadas**  
   - Métricas impresas en consola (accuracy, matriz de confusión).  
   - Gráficos de árboles y bosques en PNG.  
   - Predicciones de prueba para perfiles sintéticos (en consola).

---

## 🤖 Ejecución en Python: Redes Neuronales Densas

1. **Activar entorno**  
   - Inicie el entorno virtual y asegúrese de tener las dependencias instaladas (`pip install ...`).

2. **Abrir el notebook**  
   - `jupyter notebook redes_neuronales.ipynb` (o ábralo en VS Code).  
   - Ajuste la variable `ruta` en la primera celda para que apunte a su carpeta `datasets` local.

3. **Carga y preparación de datos**  
   - Se leen los mismos Excel usados en R, se unifican columnas y se codifican categorías (limpieza con `unidecode`, `LabelEncoder`, `to_categorical`).
   - Se separan conjuntos de entrenamiento/prueba con `train_test_split` y se escalan variables numéricas con `StandardScaler`.

4. **Arquitecturas de red**  
   - **Red 1 (año de la falta)**: capas `Dense` con activación ReLU y salida softmax para predecir `ano_boleta`.  
   - **Red 2 (tipo de falta u objetivo indicado en el notebook)**: configuración similar, con función de pérdida y activación acordes a si es binario o multiclase.  
   - Uso de `EarlyStopping` y optimizador `Adam`.  
   - Clase balanceada opcional con `compute_class_weight` según la distribución de etiquetas.

5. **Entrenamiento y evaluación**  
   - Ejecute las celdas en orden. El notebook muestra el resumen del modelo, el proceso de entrenamiento y las métricas (accuracy, matriz de confusión).  
   - Las gráficas de curvas y matrices pueden guardarse como `red_neuronal_*.png`.

6. **Resultados**  
   - Métricas y tablas impresas en el notebook.  
   - Visualizaciones de desempeño (pérdida/accuracy por época, matriz de confusión).  
   - Predicciones sobre perfiles sintéticos demostrativos.

---

## 🧠 Explicación técnica resumida

- **Árboles de decisión (`rpart`)**: dividen el espacio de atributos maximizando la ganancia de información (medida con entropía). Cada nodo evalúa variables como `sexo_inf`, `edad_inf`, `area_geo_inf`, `gran_grupos`, etc.; las hojas asignan la clase mayoritaria. Las gráficas `arbol_*.png` facilitan interpretar reglas y nodos terminales.

- **Random Forest**: ensamble de múltiples árboles entrenados sobre subconjuntos de variables/filas. Se controlan parámetros como número de árboles (`ntree`) y número de variables por split (`mtry`). La importancia de variables se reporta en los gráficos `random_forest_*.png`, útil para comparar qué atributos aportan más a la predicción de falta, sexo o área.

- **Redes neuronales densas (Keras)**: modelos `Sequential` con capas `Dense` y activaciones ReLU; la capa de salida usa softmax (multiclase) o sigmoid (binario). Se normalizan entradas y se aplican callbacks de parada temprana. Las métricas principales son accuracy y matriz de confusión sobre el conjunto de prueba.

---

## 🔁 Reproducibilidad y buenas prácticas
- El script en R fija semillas (`set.seed(42)`) antes de entrenar Random Forest; puede ajustarlas para replicar exactamente los resultados.
- En Python, defina semillas manualmente (`np.random.seed(...)`, `tf.random.set_seed(...)`) si necesita ejecuciones deterministas.
- Revise que no existan valores faltantes inesperados tras la limpieza y que las columnas categóricas queden correctamente codificadas.
- Si ejecuta en entornos sin interfaz gráfica, configure la salida de plots a archivos PNG en lugar de mostrarlos en pantalla.

---

## 👤 Autor
**Rodrigo Eduardo Hernández Morales**  
Maestría en Ciencia de la Computación – Especialidad en Ciencia de Datos  
Universidad de San Carlos de Guatemala
