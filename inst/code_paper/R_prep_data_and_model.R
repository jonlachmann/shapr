library(xgboost)
library(data.table)

path_data_and_model <- "./inst/code_paper/data_and_models/"

# Bike sharing data from http://archive.ics.uci.edu/dataset/275/bike+sharing+dataset
# with license https://creativecommons.org/licenses/by/4.0/

temp <- tempfile()
url <- "https://archive.ics.uci.edu/static/public/275/bike+sharing+dataset.zip"
download.file(url, temp)
bike <- fread(unzip(temp, "day.csv"))
unlink(temp)

# Following the data preparation done by
# Heskes, T., Sijben, E., Bucur, I. G., & Claassen, T. (2020).
# Causal shapley values: Exploiting causal knowledge to explain individual predictions of complex models.
# Advances in neural information processing systems, 33, 4778-4789.
# (See supplement: https://proceedings.neurips.cc/paper_files/paper/2020/file/32e54441e6382a7fbacbbbaf3c450059-Supplemental.zip)

bike[,trend := as.numeric(difftime(dteday,
                                   dteday[1],
                                   units = "days"))]

bike[,cosyear :=cospi(trend / 365 * 2)]
bike[,sinyear :=sinpi(trend / 365 * 2)]
bike[,temp := temp * (39 - (-8)) + (-8)]
bike[,atemp := atemp * (50 - (-16)) + (-16)]
bike[,windspeed := 67 * windspeed]
bike[,hum := 100 * hum]


# We specify the features and the response variable.
x_var <- c("trend", "cosyear", "sinyear",
           "temp", "atemp", "windspeed", "hum")
y_var <- "cnt"

# We split the data into a training ($80\%$) and test ($20\%$) data set, and we compute $\phi_0$.
set.seed(123)
train_index <- sample(x = nrow(bike), size = round(0.8*nrow(bike)))

x_full <- bike[, mget(x_var)]

x_train <- bike[train_index, mget(x_var)]
y_train <- bike[train_index, get(y_var)]

x_explain <- bike[-train_index, mget(x_var)]
y_explain <- bike[-train_index, get(y_var)]

# We fit the a basic xgboost model to the training data.
model <- xgboost::xgboost(
  data = as.matrix(x_train),
  label = y_train,
  nround = 100,
  verbose = FALSE
)

#### Writing training and explanation data to csv files
fwrite(x_full, file=file.path(path_data_and_model,"x_full.csv"))
fwrite(x_train, file=file.path(path_data_and_model,"x_train.csv"))
fwrite(as.data.table(y_train), file=file.path(path_data_and_model,"y_train.csv"))
fwrite(x_explain, file=file.path(path_data_and_model,"x_explain.csv"))
fwrite(as.data.table(y_explain), file=file.path(path_data_and_model,"y_explain.csv"))

# We save the xgboost model object
xgboost::xgb.save(model, file.path(path_data_and_model,"xgb.model"))
saveRDS(model, file.path(path_data_and_model,"model.rds"))


