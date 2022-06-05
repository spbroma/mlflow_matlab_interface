# Minimalistic Matlab interface to MLflow
via [REST API](https://www.mlflow.org/docs/latest/rest-api.html), based on [REST API example for Python](https://github.com/mlflow/mlflow/tree/master/examples/rest_api). Also you can find extended REST API example for Python [here](https://github.com/spbroma/MLflow-REST-API-basic) ([original](https://gitee.com/yichaoyyds/mlflow-ex-restapi-basic.git)).

### Instructions

1. Install MLflow to yout python environment:
```bash
pip install mlflow
```

2. Run MLflow server:
```bash
mlflow server
```
*for specifying IP, port, etc, go to [documentation](https://www.mlflow.org/docs/latest/cli.html#mlflow-server)*

3. Open `127.0.0.1:5000` in your browser.  

4. Run `example.m` in Matlab.  

### Todos
 - accelerate `MLflowTrackingRestApi.post()` execution
 - add remaining functions

 Currently implemented 5/42 functions:
 - `create_run`
 - `create_experiment`
 - `list_experiments`
 - `log_param`
 - `log_metric`

