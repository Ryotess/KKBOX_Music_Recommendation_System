#----------------------Load libraries------------------------------#
library(data.table)
library(lightgbm)
library(Matrix)
library(tidyverse)
library(readr)
library(R.utils)
library(caret)
library(irlba)
#--------------------------Load data------------------------------#
train <- read_csv('./Data/train.csv')
test <- read_csv('./Data/test.csv')
songs <- read_csv('./Data/songs.csv')
members <- read_csv('./Data/members.csv')
songs_extra <- read_csv('./Data/song_extra_info.csv')
#--------------------------members------------------------------#
## bd < 13 => 12, > 74 => 75
members$bd[members$bd < 13] <- 12
members$bd[members$bd > 74] <- 75
## Year/Month/Day
members$registration_init_time <- as.character(members$registration_init_time)
members$expiration_date <- as.character(members$expiration_date)
# Y/M/D reg
members$reg_year <- as.numeric(substr(members$registration_init_time, 1, 4))
members$reg_month <- as.numeric(substr(members$registration_init_time, 5, 6))
members$reg_day <- as.numeric(substr(members$registration_init_time, 7, 8))
# Y/M/D exp
members$exp_year <- as.numeric(substr(members$expiration_date, 1, 4))
members$exp_month <- as.numeric(substr(members$expiration_date, 5, 6))
members$exp_day <- as.numeric(substr(members$expiration_date, 7, 8))
# Drop original columns
members <- subset(members, select = -c(registration_init_time,expiration_date))
#--------------------------songs------------------------------#
genre <- separate(data = songs[,3], col = genre_ids,
         into = c("g1", "g2", "g3", "g4", "g5", "g6", "g7"),
         sep = "\\|")
g <- sort(table(unlist(genre)), decreasing = T)
# barplot(c(sum(g[1:5]),sum(g[6:191])))
pop_genre <- names(g[1:5])
set_genre <- function(x){
  if(sum(na.omit(x) %in% pop_genre) > 0){
    return('pop')
  }else{
    return('other')
  }
}
songs$genres <- apply(genre, 1, set_genre)
songs <- subset(songs, select = -c(genre_ids))
#--------------------------songs_extra------------------------------#
## ISRC
isrc_to_year <- function(isrc) {
  if (!is.na(isrc)) {
    year <- as.numeric(substr(isrc, 6, 7))
    if (year > 17) {
      return(1900 + year)
    } else {
      return(2000 + year)
    }
  } else {
    return(NA)
  }
}
songs_extra$song_year <- sapply(songs_extra$isrc, isrc_to_year)
songs_extra <- songs_extra %>% select(-isrc, -name)
# song_age
songs_extra$song_age <- 2018 - songs_extra$song_year
#--------------------------Train test------------------------------#
## Similarity
# user_songs <- train[,1:2]
# # 建立稀疏矩陣
# user_song_matrix <- sparseMatrix(i = 1:nrow(user_songs),
#                                  j = match(user_songs$msno, unique(user_songs$msno)),
#                                  x = 1,
#                                  dimnames = list(user_songs$song_id, unique(user_songs$msno)))
# 
# # 計算用戶和歌曲的相似度矩陣（內積）
# user_song_similarity <- crossprod(user_song_matrix)
# 
# # 執行稀疏奇異值分解（Sparse SVD）
# svd_result <- irlba(user_song_similarity, nv = 10)  # 假設選擇前 10 個奇異值
# 
# # 獲取用戶特徵矩陣
# user_features <- svd_result$u
# 
# # 獲取歌曲特徵矩陣
# song_features <- svd_result$v
# 
# # 建立包含 song_id 和 msno 的特徵矩陣
# user_features <- cbind(song_id = rownames(user_song_similarity), user_features)
# song_features <- cbind(msno = colnames(user_song_similarity), song_features)

## 
user_songs <- rbind(train[,1:2], test[,2:3])
setDT(user_songs)
# unique_songs
user_songs[, unique_songs := uniqueN(song_id), by = msno]
# popularity
user_songs[, popularity := uniqueN(msno), by = song_id]

## 1. Calculate number of times played
song_played_count_train <- train %>% count(song_id) %>% as.data.frame()
song_played_count_test <- test %>% count(song_id) %>% as.data.frame()
# All songs in train and test
song_played_count <- rbind(song_played_count_train,song_played_count_test)
colnames(song_played_count) <- c('song_id', 'number_of_time_played')
# Drop duplicates and keep the first one(train is prior to test)
song_played_count <- song_played_count[!duplicated(song_played_count$song_id), ]
## 2. Calculate user activity
user_activity_train <- train %>% select(msno) %>% count(msno) %>% as.data.frame()
user_activity_test <- train %>% select(msno) %>% count(msno) %>% as.data.frame()
# All members in train and test
user_activity <- rbind(user_activity_train, user_activity_test)
colnames(user_activity) <- c('msno', 'user_activity')
# Drop duplicates and keep the first one(train is prior to test)
user_activity <- user_activity[!duplicated(user_activity$msno), ]
#--------------------------Merge Features------------------------------#
# Merge the `ms` in data
train <- merge(train, user_activity, by = 'msno', all.x = TRUE)
test <- merge(test, user_activity, by = 'msno', all.x = TRUE)

# Merge the `song_played_count` in data
train <- merge(train, song_played_count, by = 'song_id', all.x = TRUE)
test <- merge(test, song_played_count, by = 'song_id', all.x = TRUE)

# popularity/unique_songs
# unique_songs
unique_songs <- distinct(user_songs[,c(1,3)], msno, .keep_all = TRUE)
# popularity
popularity <- distinct(user_songs[,c(2,4)], song_id, .keep_all = TRUE)

train <- merge(train, unique_songs, by = 'msno', all.x = TRUE)

test <- merge(test, unique_songs, by = 'msno', all.x = TRUE)

train <- merge(train, popularity, by = 'song_id', all.x = TRUE)

test <- merge(test, popularity, by = 'song_id', all.x = TRUE)
# songs_extra
train <- merge(train, songs_extra, by = 'song_id', all.x = TRUE)
test <- merge(test, songs_extra, by = 'song_id', all.x = TRUE)
# songs
train <- merge(train, songs, by = 'song_id', all.x = TRUE)
test <- merge(test, songs, by = 'song_id', all.x = TRUE)
# members
train <- merge(train, members, by = 'msno', all.x = TRUE)
test <- merge(test, members, by = 'msno', all.x = TRUE)
#----------------------Prepare to modeling------------------------#
rm(train3)
## Another Feature
train$age_gap <- train$bd - train$song_age
test$age_gap <- test$bd - test$song_age
# # Remove unnecessary objects
# rm(members, songs, songs_extra)
gc()
# # Convert categorical columns to factors
# cate <- c("msno" ,"song_id", "source_system_tab", "source_screen_name",
#           "source_type", "artist_name", "composer", "lyricist",
#           "language", "genres", "city", "registered_via")
# 
# for (i in cate){
#   train[i] <- as.factor(train[i])
#   test[i] <- as.factor(test[i])
# }

# Convert character columns to factors
train[] <- lapply(train, function(x) if (is.character(x)) as.factor(x) else x)
test[] <- lapply(test, function(x) if (is.character(x)) as.factor(x) else x)

# Prepare data for training
X <- train %>% select(-target)
y <- train$target
X_test <- test %>% select(-id)
ids <- test$id
# rm(train, test)
gc()
print('Training LGBM model...')
#---------------------Modeling------------------------------#
# Train the LightGBM model
lgb_train <- lgb.Dataset(data = as.matrix(X), label = y)

params <- list(objective = "binary",
               metric = 'auc',
               boosting = 'gbdt',
               learning_rate = 0.2,
               verbose = 0,
               num_leaves = 250,
               bagging_fraction = 0.95,
               bagging_freq = 1,
               bagging_seed = 1,
               feature_fraction = 0.9,
               feature_fraction_seed = 1,
               max_depth = 20,
               num_rounds = 500)

lgb_model <- lgb.train(params = params, data = lgb_train)

#---------------------Submit------------------------------#
# Make predictions and save them
p_test <- predict(lgb_model, as.matrix(X_test))
subm <- data.frame(id = ids, target = p_test)
write_csv(subm, "submission.csv")

print('Done!')