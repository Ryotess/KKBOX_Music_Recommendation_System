# Project Information

![image](https://github.com/Ryotess/KKBOX_Music_Recommendation_System/assets/107910175/8e97f804-9e55-4b6b-b20b-d218b169610a)

This repository is the Top 30%/AUC > 0.68 solution for KKBOX recommender competition.  
We use feature engineering technigues such as SVD, outlier removal and recommendation theory: user-item matrix to reach the ranking.  
 
## Quick start

**!! Directly run the R file is not recommended!!**  

Instead, you can open the .ipynb(Python version) file to demo the project with a lower computation cost.  
If you have any technical problem, feel free to contact us.

## Folder organization and its related description
### Competition Page
[WSDM - KKBox's Music Recommendation Challenge (2018) ](https://www.kaggle.com/competitions/kkbox-music-recommendation-challenge) 

### Data
**The following is the link of data**  
* Input
  * Source: [Datasets](https://www.kaggle.com/competitions/kkbox-music-recommendation-challenge/data)
* Output
  * Format:CSV file, 2 columns(ID, target)

### Code
* Preprocess
  * Remove outliers
  * Members feature extraction
  * Songs feature extraction
  * Song_extra_info feature extraion
  * User-Song Matrix SVD

* Model
  * LightGBM

* Metric
  * AUC

### results
* Top 300 Private Score(AUC 0.68)

## References
* pandas/numpy/scipy/sklearn/lightgbm
* Koren, Yehuda; Bell, Robert; Volinsky, Chris (August 2009). "Matrix Factorization Techniques for Recommender Systems". Computer. 42 (8): 30–37. CiteSeerX 10.1.1.147.8295. doi:10.1109/MC.2009.263. S2CID 58370896.
