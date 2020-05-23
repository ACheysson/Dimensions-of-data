% % This script solves the baseline monopoolistic model. It does so for a range of
% different parameters and produces graphs accordingly. For one time runs,
% one needs to specify manually parameters at the beginning of the script.
% First load the subfunctions of the code


path_to_sub = which('monopole.m');
path_to_sub = strrep(path_to_sub, 'monopole.m', '');
addpath([path_to_sub, 'subfunctions'])

% First specify whether it will be investigation over a range of parameters
N_runs = 1;

% Do you want graphs?
graphs = 0; % graphs will slow down significantly the code

% Specify parameter values
alpha = 1;          % Define how strong is the horizontal differenciation
prior  = 0.8;         % Define Markov Chain persistence

% Specify storing vectors
value_of_info = zeros(N_runs,1);    % Value of information
p_first = zeros(N_runs,1);     % Prices in the first period
p_second = zeros(N_runs,2);    % first column informed, second not informed

% Specify around which to run
prior_vec = linspace(0.5, 0.8, N_runs);

% Ready to start the loop
disp('Start loop over parameter specification')
for ii = 1:N_runs
    
   % Unpack parameter we loop around
    prior = prior_vec(ii);
    
    
    % Compute second period price with information
    [p_second(ii,1), share_info, pi_info, cs_info] = optimal_monopole(0, prior, alpha);
    
    % Compute second period price without info
    [p_second(ii,2), share_not, pi_not, cs_not] = optimal_monopole(0, 0.5, alpha);
    
    % Compute value of information
    voi = pi_info - pi_not;
    
    % Compute first period prices
    [p_first, share_first, pi_first, cs_first] = optimal_monopole(voi, 0.5, alpha);
    
end
