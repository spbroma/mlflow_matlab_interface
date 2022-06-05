classdef MLflowTrackingRestApi < handle
    properties
        base_url = '';
        experiment_id = '';
        run_id = '';
    end

    methods

        function obj = MLflowTrackingRestApi(hostname, port, experiment_id)
            if nargin < 3
                experiment_id = 0;
            end
            obj.base_url = ['http://', hostname, ':', num2str(port), '/api/2.0/preview/mlflow'];
            obj.experiment_id = experiment_id;
        end

        function time = timestamp(obj)
            time = num2str(floor(posixtime(datetime('now','TimeZone','local'))*1000));
        end

        function out = struct2json(obj, s)
            s_fields = fields(s);
            out = '{';
            for i = 1:length(s_fields)
                f = s_fields{i};
                v = s.(f);
                if isnumeric(v)
                    v = num2str(v);
                else
                    v = ['"' v '"'];
                end
                out = [out '"' f '":' v ','];
            end
            out = [out(1:end-1) '}'];
        end

        function out = post(obj, url, data)
            % Need to accelerate
            data_json = jsonencode(data);
            request = matlab.net.http.RequestMessage( 'POST', ...
                [matlab.net.http.field.ContentTypeField( 'application/vnd.api+json' ), ...
                 matlab.net.http.field.AcceptField('application/vnd.api+json')], ...
                 data_json );
            response = request.send(url);
            out = response;
        end

        function obj = create_run(obj)
            url = [obj.base_url, '/runs/create'];
            payload.experiment_id = obj.experiment_id;
            payload.start_time = obj.timestamp();

            payload.tags = '[{"key":"runName", "value":"test"}]';

            resp = obj.post(url, payload);
            if isequal(resp.StatusCode , 'OK')
                obj.run_id = resp.Body.Data.run.info.run_uuid;
            else
                warning("Creating run failed!");
                obj.run_id = nan;
            end
        end

        function obj = create_experiment(obj, name)
            url = [obj.base_url, '/experiments/create'];
            payload.name = name;

            resp = obj.post(url, payload);
            if isequal(resp.StatusCode , 'OK')
                obj.experiment_id = resp.Body.Data.experiment_id;
            else
                error(resp.Body.Data.message);
            end
        end

        function experiments = list_experiments(obj)
            % Get all experiments.

            url = [obj.base_url, '/experiments/list'];
            resp = urlread(url);
            try
                resp = jsondecode(resp);
                experiments = resp.experiments;
            catch
                disp(resp);
                experiments = nan;
            end
        end

        function status = log_param(obj, param, value)
            % Log a parameter for the given run.

            url = [obj.base_url, '/runs/log-parameter'];
            payload.run_uuid = obj.run_id;
            payload.key = param;
            if isnumeric(value)
                value = num2str(value);
            end
            payload.value = value;

            r = obj.post(url, payload);
            status = r.StatusCode;
        end

        function status = log_metric(obj, metric, value, varargin)
            % Log a metric for the given run.

            url = [obj.base_url, '/runs/log-metric'];

            p = inputParser;
            addOptional(p,'step', 0);
            parse(p,varargin{:});

            step = p.Results.step;

            payload.run_uuid = obj.run_id;
            payload.key = metric;
            payload.value = num2str(value);
            payload.timestamp = obj.timestamp();
            payload.step = num2str(step);

            r = obj.post(url, payload);
            status = r.StatusCode;
        end
    end
end