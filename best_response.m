% Here we code the model, start with the second period
s_1 = 0.55;
alpha = 1;
beta = 0.9;
fineness = 100;
p_grid = linspace(0.01, alpha+1,fineness)';

%% Second period
% Compute the best responses
[sols_inf, market_share_inf, profits_inf] = compute_best_response_info(p_grid, alpha, s_1);
[sols_uninf, ~, ~, ~] = compute_best_response_uninfo(p_grid, alpha, s_1, 1);

% Plot the best response intersection
figure;
plot(p_grid, sols_inf)
hold on
plot(sols_uninf, p_grid)
ylabel('Price of informed')
xlabel('Price of uninformed')

[sols_uninf, market_share_uninf_type_1, market_share_uninf_type_2, profits_uninf] = compute_best_response_uninfo(sols_inf, alpha, s_1, 0);

% Fixed point contains the intersection of the nash curves. Compute the "value of information"
[distance, fixed_point]= min(abs(p_grid-sols_inf));
additional_gain = profits_inf(fixed_point) - profits_uninf(fixed_point);


%% First period

% Compute the first period equilibrium conditional on this value
[sols, market_share] = first_period(p_grid, additional_gain, alpha, beta);
disp(['The value of information:' num2str(additional_gain)])

% Now we can compute optimal prices
[opt_price, fixed_point_1] = min(abs(p_grid - sols));

% Display optimal pricing in period 1

