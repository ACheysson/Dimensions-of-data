% This script solves the baseline duopolistic model. It does so for a range of
% different parameters and produces graphs accordingly. For one time runs,
% one needs to specify manually parameters at the beginning of the script.

% First load the subfunctions of the code
path_to_sub = which('duopole.m');
path_to_sub = strrep(path_to_sub, 'duopole.m', '');
addpath([path_to_sub, 'subfunctions'])

% First specify whether it will be investigation over a range of parameters
N_runs = 1;

% Do you want graphs?
graphs = 1; % graphs will slow down significantly the code

% Specify parameter values
fineness = 100;     % Define how precise is the grid of prices we search on
alpha = 1;          % Define how strong is the horizontal differenciation
s_1  = 0.8;         % Define Markov Chain persistence 
p_grid = linspace(0, alpha+0.5,fineness)'; % Possible values of prices

% Specify storing vectors
value_of_info = zeros(N_runs,2);    % Value of information, 1st is high to low, second is medium to low
prices_info = zeros(N_runs, 1);    % Price schedule of uninformed platform
prices_not = zeros(N_runs,1);       % Price schedule of informed platform
prices_first = zeros(N_runs,1);

% Specify around which to run
s_vec = linspace(0.5, 0.8, N_runs);

% Ready to start the loop
disp('Start loop over parameter specification')
for ii = 1:N_runs

    % Unpack parameter we loop around
    s_1 = s_vec(ii);
    
    % Compute best response schedule of informed platform
    [p_info, market_info, profits_info] = br_info(p_grid, alpha, s_1,graphs);
    
    % To compute best response schedule and intersection of best responses
    if graphs == 1
        [p_not, ~, ~] = br_not(p_grid, alpha, s_1, 1);
        
        figure
        plot(p_grid, p_info)
        hold on
        plot(p_not, p_grid)
        ylabel('Price of informed')
        xlabel('Price of uninformed')
    end
    
    % Compute the best response of uninformed to the best response of informed
    [p_not, market_not, profits_not] = br_not(p_info, alpha, s_1, 0);
    
    % We can now find the value of the intersection and the parameters of the model at the intersection
    [distance, fixed_point]= min(abs(p_grid-p_not));
    
    % Send a warning if the distance is too high
    if distance > 1/fineness
        warning('It does not look like a good intersection of best responses was found in 2nd period')
        fprintf('%0.2f \n', distance)
    end
    
    % Store the values
    value_of_info(ii,1) = profits_info(fixed_point) - profits_not(fixed_point);
    prices_info(ii) = p_info(fixed_point);
    prices_not(ii) = p_not(fixed_point);
    
    % Now we want to compute the value of information from medium to low
    [p_equal, market_equal, profits_equal] = br_equal(p_grid, 0, 0, alpha, graphs);
    
    % Find the fixed point
    [distance, fixed_point] = min(abs(p_grid - p_equal));
    
    % Do a simple check
    if distance > 1/fineness
        warning('It does not look like a good intersection of best responses was found in first period')
        fprintf('%0.2f \n', distance)
    end
    
    % Compute value from medium to low
    value_of_info(ii,2) = profits_equal(fixed_point) - profits_not(fixed_point);
    
    % We can now compute the first period of the model
    [p_first, ~] = br_equal(p_grid, value_of_info(ii, 1), value_of_info(ii,2), alpha, graphs);
    [distance, fixed_point] = min(abs(p_grid - p_first));
    
    % Send another warning in case of problem
    if distance > 1/fineness
        warning('It does not look like a good intersection of best responses was found in first period')
        fprintf('%0.2f \n', distance)
    end
    
    % And compute the first period prices
    p_first(ii) = p_grid(fixed_point);
    
    % Print completion rate
    disp(['Completion rate:' num2str(100*round(ii/N_runs,2)) '%'])
end