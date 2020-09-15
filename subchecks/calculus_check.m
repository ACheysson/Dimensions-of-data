% First check out the monopoly case
options = optimoptions('fmincon', 'Display','off', 'OptimalityTolerance', 1e-10);
tolf = 1e-7;

%% Prices to upper bound 

% Put parameters such that prices
tet_a = 2.2 + randn()/10;
gamma = 0.25 + randn()/10;
tet_b = 3 + randn()/10;
p_b = 2.5 + randn()/10;
inequality = tet_a/2 - (1-gamma)/gamma * (tet_b - p_b);

if inequality >= 0
    error('First check won''t work because inequality is not of the right side')
end

% Here is what I computed by hands
predicted_price = tet_a - (1-gamma)/gamma * (tet_b - p_b);
predicted_quant = (tet_b - p_b)/gamma;

% Now let's see what our model does
upper_bound = tet_a - (1-gamma)/gamma * (tet_b - p_b);
profits = @(p) - p * (tet_a - p)/(1-gamma);

[price,profit,~] = fmincon(profits, predicted_price, 1, upper_bound, [], [], [], [], [], options);

if abs(price - predicted_price) > tolf
    disp('Wrong prices predicted')
elseif abs(-profit/price - predicted_quant) > tolf
    disp('Wrong quantities predicted')
end

%% Prices free

tet_a = 5 + randn()/10;
gamma = 0.25 + randn()/10;
tet_b = 3 + randn()/10;
p_b = 2.5 + randn()/10;
inequality = tet_a/2 - (1-gamma)/gamma * (tet_b - p_b);

if inequality <= 0
    error('First check won''t work because inequality is not of the right side')
end

% Here is what I computed by hands
predicted_price = tet_a/2;
predicted_quant = tet_a/(2*(1-gamma));

% Now let's see what our model does
upper_bound = tet_a - (1-gamma)/gamma * (tet_b - p_b);
profits = @(p) - p * (tet_a - p)/(1-gamma);

% Now solve
[price,profit,~] = fmincon(profits, predicted_price, 1, upper_bound, [], [], [], [], [], options);

if abs(price - predicted_price) > tolf
    disp('Wrong prices predicted')
elseif abs(-profit/price - predicted_quant) > tolf
    disp('Wrong quantities predicted')
end

%% Balanced case

% Demand computation
tet_a = 3.5 + randn()/10;
p_a = 2.5 + randn()/10;
gamma = 0.25 + randn()/10;
tet_b = 3 + randn()/10;
p_b = 2.5 + randn()/10;

% Here is the utility function
utility_func = @(x) - (tet_a*x(1) + tet_b*x(2) - (1-gamma)/2 *(x(1)^2 + x(2)^2) - gamma*x(1)*x(2) - p_a*x(1) - p_b*x(2));

% Here is the predicted demand
predicted_q_a = (1-gamma)/(1-2*gamma) * (tet_a - p_a) - gamma/(1-2*gamma) * (tet_b - p_b);

% here is the optimisation
[quant,util,~] = fmincon(utility_func, [1,1], [-1,0;0,-1], [0,0], [], [], [], [], [], options);

if abs(price - predicted_price) > tolf
    disp('Wrong prices predicted')
elseif abs(-profit/price - predicted_quant) > tolf
    disp('Wrong quantities predicted')
end

% Supply computations
tet_a = 5 + randn()/10;
gamma = 0.25 + randn()/10;
tet_b = 3 + randn()/10;
p_b = 2.5 + randn()/10;
inequality = tet_a - gamma/(1-gamma) * (tet_b - p_b);

if inequality <= 0
    error('First check won''t work because inequality is not of the right side')
end

% Here is what I computed by hands
predicted_price = tet_a/2 - gamma/(2*(1-gamma)) * (tet_b -p_b);
predicted_quant = (1-gamma)/(1-2*gamma) * tet_a/2 - 1/2 * gamma/(1-2*gamma) * (tet_b - p_b);

% Now let's see what our model does
profits = @(p) - p * ((1-gamma)/(1-2*gamma) * (tet_a - p) - gamma/(1-2*gamma) *(tet_b - p_b));

% Now solve
[price,profit,~] = fmincon(profits, predicted_price, -1, 0, [], [], [], [], [], options);

if abs(price - predicted_price) > tolf
    disp('Wrong prices predicted')
elseif abs(-profit/price - predicted_quant) > tolf
    disp('Wrong quantities predicted')
end


%% Check best responses are really the ones we imagine
tet_a = 5 + randn()/10;
gamma = 0.25 + randn()/10;
tet_b = 3 + randn()/10;

% Compute computations help
gammas_on_left = (4*(1-gamma)^2 - gamma^2)/(1-gamma);
gammas_on_right = (2*(1-gamma)^2 - gamma^2)/(1-gamma);
p_a_predict = (gammas_on_right * tet_a - gamma*tet_b)/gammas_on_left;
p_b_predict = (gammas_on_right * tet_b - gamma*tet_a)/gammas_on_left;

profits = @(p) - p * ((1-gamma)/(1-2*gamma) * (tet_a - p) - gamma/(1-2*gamma) * (tet_b - p_b_predict));
[price,profit,~] = fmincon(profits, .5, -1, 0, [], [], [], [], [], options);

if abs(p_a_predict - price) > tolf
    dips('there''s an error')
end

