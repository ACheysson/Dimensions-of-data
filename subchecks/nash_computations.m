% Model parameters
tet_a_base = 3;
gamma = 0.25;
tet_b = 3;
options = optimoptions('fmincon', 'Display','off', 'OptimalityTolerance', 1e-10);

% Number of trials we do
N = 100;
test = linspace(0,15,N);
profit = zeros(3,N);

for ii = 1:N
    % Boost tet_a by the proper amount
    tet_a = tet_a_base + test(ii);
    
    % We can deal nash equilibrium prices
    gammas_on_left = (4*(1-gamma)^2 - gamma^2)/(1-gamma);
    gammas_on_right = (2*(1-gamma)^2 - gamma^2)/(1-gamma);
    p_a = (gammas_on_right * tet_a - gamma*tet_b)/gammas_on_left;
    p_b = (gammas_on_right * tet_b - gamma*tet_a)/gammas_on_left;
    
    % Compute quantities traded given the prices
    utility = @(q) - (tet_a*q(1) + tet_b*q(2) - (1-gamma)/2 * (q(1)^2 + q(2)^2) - gamma*q(1)*q(2) - p_a*q(1) - p_b*q(2));
    [quantities,uti,~] = fmincon(utility, [1,1], [-1,0;0,-1], [0,0], [], [], [], [], [], options);
    
    % Compute profits
    profit(1,ii) = p_a*quantities(1);
    profit(2,ii) = p_b*quantities(2);
    
    % Check if A can decide to exclude B
    exclusion = tet_a >= (1-gamma)/gamma * tet_b;
    if exclusion
        % Then the price is
        p_a = (tet_a/2 <= (1-gamma)/gamma * tet_b) * (tet_a - (1-gamma)/gamma *tet_b) + ...
              (tet_a/2 > (1-gamma)/gamma * tet_b) * (tet_a/2);
        % And the quantity is
        q_a = (tet_a - p_a)/(1-gamma);
        
        % So the profits are
        profit(3,ii) = q_a*p_a;
    end
    
end