
# Project Information


## Quick start

**!! Directly run the R file is not recommended, since the memory requirement is really high.!!**  
Instead, you can open the .ipynb(Python version) file to demo the project with a lower computation cost.  
If you have any technical problem, feel free to contact us.

## Folder organization and its related description
### Competition Page
[WSDM - KKBox's Music Recommendation Challenge (2018) ](https://www.kaggle.com/competitions/kkbox-music-recommendation-challenge) 
### docs
* PPT

### data
**Since the sizes of data files exceeded Github's upload limit, we leave the data source link down below for you to download**  
* Input
  * Source: [Datasets](https://www.kaggle.com/competitions/kkbox-music-recommendation-challenge/data)
* Output
  * Format:CSV file, 2 columns(ID, target)

### code
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
* Packages you use
* Related publications
