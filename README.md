# 📊 Proyecto de Integración, Limpieza y Modelado de Faltas Judiciales (2018–2024)

Este repositorio reúne los pasos necesarios para integrar las bases anuales de faltas judiciales, limpiarlas y ejecutar modelos de **árboles de decisión, bosques aleatorios y redes neuronales**. El flujo cubre tanto la implementación en **R (Fase_2.R)** como en **Python (notebook `redes_neuronales.ipynb`)**, de modo que cualquier analista pueda replicar el preprocesamiento y los experimentos de modelado en su propio entorno.

---

## 📁 Estructura del proyecto

```
/Proyecto_Fase_2/
├── Fase_2.R                   # Script principal en R (árboles y random forest)
├── redes_neuronales.ipynb     # Notebook en Python/TensorFlow para red neuronal
├── datasets/                  # Carpeta con los archivos Excel originales
│   ├── faltas-judiciales-ano-2018.xlsx
│   ├── faltas-judiciales-ano-2019.xlsx
│   ├── faltas-judiciales-ano-2020.xlsx
│   ├── faltas-judiciales-ano-2021.xlsx
│   ├── faltas-judiciales-ano-2022.xlsx
│   ├── faltas-judiciales-2023.xlsx
│   └── base-faltas-judiciales-2024.xlsx
├── arbol_*.png                # Gráficas exportadas de los árboles de decisión
├── random_forest_*.png        # Gráficas/artefactos del modelo de Random Forest
└── red_neuronal_*.png         # Gráficas de la red neuronal
```

> ℹ️ Los archivos `*.png` son ejemplos generados al ejecutar los modelos. Se pueden regenerar ejecutando los scripts/notebooks con capacidades gráficas.

---

## ⚙️ Requisitos generales

### Datos
Coloque los Excel anuales dentro de `datasets/` y asegúrese de que el nombre incluya el año en cuatro dígitos (`faltas-judiciales-ano-2021.xlsx`, etc.). El código usa esa cadena para inferir el año de cada archivo.

### Sistema operativo
Funciona en **Windows, macOS o Linux**. Ajuste las rutas de los datos según su sistema.

### R (Fase_2.R)
- **Versión:** R 4.2 o superior.
- **IDE recomendado:** RStudio.
- **Paquetes:**
  ```r
  install.packages(c(
    "readxl", "stringi", "dplyr", "arules", "rpart", "rpart.plot",
    "randomForest", "entropy"
  ))
  ```

### Python (notebook `redes_neuronales.ipynb`)
- **Versión:** Python 3.10+ recomendado.
- **Entorno:** Jupyter Notebook o VS Code con soporte para notebooks.
- **Paquetes principales:**
  ```bash
  pip install numpy pandas tensorflow scikit-learn unidecode
  ```

---

## 🚀 Ejecución en R (Fase_2.R)

1. **Configurar la ruta de trabajo**
   - Abra `Fase_2.R` y edite la línea `ruta <- ".../datasets"` para que apunte a su carpeta local de datos. Ejemplos:
     - Windows: `"D:/Proyectos/Proyecto_Fase_2/datasets"`
     - macOS/Linux: `"/home/usuario/Proyecto_Fase_2/datasets"`

2. **Cargar y limpiar los datos**
   - El script recorre automáticamente todos los `.xlsx`, extrae el año del nombre y estandariza los nombres de columnas (minúsculas, sin acentos, homologación de `gran_grupos`, `subg_principales`, etc.).
   - Se descartan columnas inconsistentes (`edad_quinquenales`, `ocupacionhabitual`, `filter_$`) y se convierte `area_geo_inf` a numérico antes de consolidar los años 2020–2024 en `df_final`.

3. **Medir información y preparar variables**
   - Calcula la entropía de `falta_inf` y el **information gain** de variables clave (`sexo_inf`, `edad_inf`, `depto_boleta`, etc.) para identificar atributos predictivos.

4. **Árboles de decisión**
   - Modelo `a_1`: predice el tipo de falta (`falta_inf`) con variables sociodemográficas y geográficas.
   - Modelo `a_2`: clasifica al infractor en grupos etarios (`edad_quinquenal`).
   - Ambos árboles se grafican con `rpart.plot` y se pueden probar con perfiles sintéticos definidos en el script.

5. **Bosques aleatorios**
   - Entrene Random Forest sobre `df_final` para comparar importancia de variables y precisión frente a los árboles simples. Las gráficas se exportan a `random_forest_*.png`.

6. **Ejecutar todo el flujo**
   - Desde RStudio: *Source* (`Ctrl + Shift + Enter`).
   - Desde terminal: `Rscript Fase_2.R`.

---

## 🤖 Ejecución en Python (notebook `redes_neuronales.ipynb`)

1. **Abrir el notebook** en Jupyter o VS Code y ajustar la variable `ruta` al directorio `datasets` de su máquina.
2. **Carga y limpieza**
   - Igual que en R, se leen todos los Excel, se estandarizan nombres y se eliminan columnas irrelevantes. Los dataframes de 2020–2024 se concatenan en `df_final` y se elimina `num_corre`.
3. **Preparación de variables**
   - Conversión de `area_geo_inf` a numérico y codificación de categorías (con `LabelEncoder`/`to_categorical`) según las celdas del notebook.
4. **Modelo de red neuronal**
   - Arquitectura `Sequential` con capas `Dense`, `Dropout` y optimizador `Adam`.
   - Escalado previo con `StandardScaler` y entrenamiento con `EarlyStopping` para evitar sobreajuste.
   - Las métricas y curvas de entrenamiento se registran y pueden graficarse (`red_neuronal_*.png`).
5. **Ejecución**
   - Ejecute las celdas en orden. El notebook incluye bloques para explorar `df_final`, preparar conjuntos de entrenamiento/prueba y entrenar la red.

---

## 🧪 Validación y salidas esperadas
- **Gráficas de árboles**: archivos `arbol_1.png`–`arbol_4.png` generados por `rpart.plot` muestran la estructura de decisión para faltas y edades.
- **Random Forest**: métricas de precisión y gráficos de importancia de variables (`random_forest_*.png`).
- **Red neuronal**: historial de pérdida/accuracy por época y evaluaciones sobre el conjunto de prueba (`red_neuronal_*.png`).

Revise los objetos y métricas impresos en consola/notebook para validar que la consolidación de datos y los modelos se ejecutaron sin errores.

---

## 🔧 Consejos de implementación
- Verifique la codificación de los Excel (UTF-8) si observa caracteres extraños en los nombres de columnas.
- Use `set.seed()` en R o fije las semillas de NumPy/TensorFlow para reproducibilidad.
- Si ejecuta en entornos sin interfaz gráfica, guarde las figuras en disco en lugar de mostrarlas en pantalla.

---

## 👤 Autor original
**Rodrigo Eduardo Hernández Morales**  
Maestría en Ciencia de la Computación – Especialidad en Ciencia de Datos  
Universidad de San Carlos de Guatemala
