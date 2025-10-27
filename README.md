# MSc-Thesis-PLF-Data-Analysis
## Thesis: Exploring daily bodyweight of growing-finishing pigs using 3D depth camera

**Author:** Jin Ha (Jiwon Ha)
**Affiliation:** Wageningen University & Research (WUR), Animal Production Systems Group

---

## 1. Project Overview & Problem Statement

This Master's thesis focuses on developing and evaluating an **automated, non-invasive method** for the continuous monitoring of individual pig bodyweight (BW) using **3D depth camera technology**.

### Problem
Traditional BW monitoring methods are labour-intensive and stressful for the animals. This research addresses the need for **accurate, long-term** BW tracking to derive data-driven insights for improving animal welfare and farm management.

---

## 2. Technical Stack & Methodology

This project utilised a hybrid approach combining IoT sensor data, computer vision algorithms, and advanced statistical modelling.

### Technologies Used
* Data Analysis: **R Studio** (Primary Language)
* Statistical Modeling: **Linear Mixed Model (LMM)** (using R's `lme4` package)
* Sensors/Vision: **iDOL 65 3D Depth Camera**, **RFID System**, and a **YOLO-based algorithm** for pig identification and data filtering.

### Methodology
1.  **Data Pre-processing:** Implemented a stringent **3-step cleaning rule** to identify and remove extreme outliers (e.g., daily gains > 4 kg) and low-quality measurements (e.g., less than 30 photos/day).
2.  **Expected Growth Modeling:** Applied a **5-day Moving Average** smoothing technique to mitigate noise and constructed the LMM to establish **expected growth patterns**, including random effects for individual pig and pen.
3.  **Trend Analysis:** Utilised **Quadratic (2nd-degree polynomial) Regression** and **Locally Weighted Scatterplot Smoothing (Loess)** to analyse daily growth trend lines across three distinct experiments (N > 330 pigs).

---

## 3. Key Findings & Contributions

* **Average Daily Gain (ADG):** Observed a general **linear growth trend** with a mean daily gain ranging from **0.985 kg to 1.05 kg** across experiments.
* **Deviation Detection:** Residual analysis using a **2 kg threshold** per individual per day effectively captured deviation patterns. Deviations were more prevalent towards the **conclusion of experiments**, often indicating **potential underperformance**.
* **Sex Effect (Exp 4):** Barrows exhibited higher daily growth rates until day 61, following which **gilts displayed higher daily growth rates** until slaughter.
* **Monitoring Utility:** 3D depth cameras are valuable for **long-term BW measurements** but necessitate further development in data analysis techniques for interpreting individual daily deviations.

---

## 4. Repository Structure & Code

Code files will be uploaded soon.

---

## 5. Contact & Availability

I am actively seeking roles in the AgTech/IoT and Data Analysis sectors.

* **LinkedIn:** [https://www.linkedin.com/in/jiwon-ha](https://www.linkedin.com/in/jiwon-ha)
* **Email:** haj180723@gmail.com
* **Status:** **Available to start immediately** in the Netherlands.
