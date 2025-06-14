from sklearn.ensemble import RandomForestRegressor
from shaprpy import explain
from shaprpy.datasets import load_california_housing

dfx_train, dfx_test, dfy_train, dfy_test = load_california_housing()

## Fit model
model = RandomForestRegressor(random_state=0)
model.fit(dfx_train, dfy_train.values.flatten())

## Shapr
explanation = explain(
    model = model,
    x_train = dfx_train,
    x_explain = dfx_test,
    approach = 'empirical',
    phi0 = dfy_train.mean().item(),
    seed = 1
)

print(explanation["shapley_values_est"])

"""
   explain_id      none    MedInc  HouseAge  AveRooms  AveBedrms  Population  \
1           1  2.205938 -0.628940  0.079242 -0.132975   0.120724   -0.028577   
2           2  2.205938 -0.493823  0.040432 -0.414438  -0.184523   -0.004707   
3           3  2.205938  0.312760  0.580232 -0.082696  -0.207635    0.074618   
4           4  2.205938  0.326929 -0.066831  0.028398   0.127577   -0.145233   
5           5  2.205938 -0.318477 -0.097264 -0.145516   0.145164    0.091597   

   AveOccup  Latitude  Longitude  
1 -0.246933 -0.449402  -0.200187  
2  0.151527 -0.189515  -0.091550  
3  0.935224  0.143673   0.304114  
4 -0.123510  0.136066   0.189386  
5 -0.007637  0.106746   0.295880  
"""

print(explanation["MSEv"]["MSEv"])
"""
       MSEv   MSEv_sd
1  0.548886  0.268748
"""

# Now do this for grouping as well

group = {'A': ['MedInc','HouseAge','AveRooms'],
         'B': ['AveBedrms','Population','AveOccup'],
         'C': ['Latitude','Longitude']}

explanation_g = explain(
    model = model,
    x_train = dfx_train,
    x_explain = dfx_test,
    approach = 'empirical',
    phi0 = dfy_train.mean().item(),
    group = group,
    seed = 1
)
print(explanation_g["shapley_values_est"])

"""
   explain_id      none         A         B         C
1           1  2.205937 -0.593807 -0.209397 -0.683844
2           2  2.205938 -1.227960 -0.206201  0.247563
3           3  2.205938  0.918459  0.650756  0.491075
4           4  2.205938  0.206152  0.007262  0.259368
5           5  2.205938 -0.535351 -0.014697  0.620540
"""


#### Asymmetric and causal Shapley values

# Assuming a causal ordering (just random in this case)
causal_ordering = {"A": ["MedInc"],
                   "B": ["HouseAge", "AveRooms"],
                   "C": ["AveBedrms", "Population", "AveOccup", "Latitude", "Longitude"]}


explanation_c_a = explain(
    model = model,
    x_train = dfx_train,
    x_explain = dfx_test,
    approach = 'empirical',
    causal_ordering = causal_ordering,
    asymmetric = True,
    phi0 = dfy_train.mean().item(),
    seed = 1
)
print(explanation_c_a["shapley_values_est"])

"""
   explain_id      none    MedInc  HouseAge  AveRooms  AveBedrms  Population  \
1           1  2.205938 -1.245542 -0.010467 -0.033270   0.000665   -0.041997   
2           2  2.205938 -0.535500 -0.128707 -0.476500   0.011474    0.009093   
3           3  2.205938 -0.293298  0.984528  0.641629  -0.013290   -0.067407   
4           4  2.205938  0.624469 -0.265218 -0.021049   0.052774    0.024693   
5           5  2.205938  0.153623 -0.255518 -0.014048   0.010609    0.075489   

   AveOccup  Latitude  Longitude  
1 -0.019427 -0.132135  -0.004874  
2  0.037546 -0.087807  -0.016198  
3  0.721834  0.026773   0.059520  
4 -0.056129  0.028024   0.085217  
5 -0.051461  0.117956   0.033842  
"""