clc
clear all

%% Experiment creation

% Create mlflow object
mlflow = MLflowTrackingRestApi('127.0.0.1', 5000);

% View existing experiments
exp_list = mlflow.list_experiments();
for i = 1:length(exp_list)
    disp(exp_list(i))
end

% Create new experiment, or select default if name is busy
try
    mlflow.create_experiment('my exp')
catch ME
    warning(ME.message)
    experiment_id = 0;

    % You can select expriment by id, if you know. id=0 is default
    mlflow = MLflowTrackingRestApi('127.0.0.1', 5000, experiment_id);
end

%% Main part

% Instead of previous section, you can just write
% mlflow = MLflowTrackingRestApi('127.0.0.1', 5000, 0);

mlflow.create_run();
disp(mlflow)

% 'runName' and other default tags can be defined on 'create_run' step
% List of tags: https://www.mlflow.org/docs/latest/tracking.html#system-tags
% But currently this wasn't implemented (I didn't figure out how to pass tags via REST API)
mlflow.log_param('run_name', 'new model attempt');
mlflow.log_param('arhitecture', 'FLFx10');

% Dummy example of metric logging
% MLflowTrackingRestApi.post() takes too much time to execution compared
% to python. Probably, it can be accelerated.
x1 = 0;
x2 = 0;
for i = 1:100
    disp(i)
    mlflow.log_metric('x1', x1, i);
    mlflow.log_metric('x2', x2, i);

    x1 = x1 + randn()-0.1;
    x2 = x2 + randn()-0.2;
end