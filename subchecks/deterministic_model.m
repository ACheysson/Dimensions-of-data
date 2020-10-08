% No uncertainty model

% Preference parameters
tet_a = 2;
tet_b = 2;
% How much can consumer data can actually be used (form of targetting)
alpha_a = 1;
alpha_b = 0.7;

% Parameters governing the model
gamma = 0.25;
beta = 0.27;


% It's gonna be a linear system to solve (actually quite easy I guess)
syms p_a p_b

% First define quantities as a function of prices
qa_f = @(q_a, q_b, p_a, p_b) beta/(beta^2 - gamma^2) * (tet_a + alpha_a*q_a - p_a) - gamma/(beta^2 - gamma^2) * (tet_b + alpha_b*q_b - p_b);
qb_f = @(q_a, q_b, p_a, p_b) beta/(beta^2 - gamma^2) * (tet_b + alpha_b*q_b - p_b) - gamma/(beta^2 - gamma^2) * (tet_a + alpha_a*q_a - p_a);




for p_b = .1:.01:10
    
    % Lay down the functions that determine quantities:
    q_a_p = @(p_a, p_b) beta/(beta^2 - gamma^2) * (tet_a - p_a) - gamma/(beta^2 - gamma^2) * (tet_b - p_b);
    q_b_p = @(p_a, p_b) beta/(beta^2 - gamma^2) * (tet_b - p_b) - gamma/(beta^2 - gamma^2) * (tet_a - p_a);
    
    % This establishes the level of future profits
    p_a_f = @(q_a, q_b) ((2*beta^2 - gamma^2)/(4*beta^2)*(tet_a + alpha_a*q_a) - gamma/(4*beta)*(tet_b + alpha_b*q_b)) * (1/(1-gamma^2/(4*beta^2)));
    
    
    profits = @(p_a) -( p_a*q_a_p(p_a, p_b)) + beta/(beta^2 - gamma^2)*p_a_f(q_a_p(p_a, p_b), q_b_p(p_a,p_b))^2);
    
    [price,profit,~] = fmincon(profits, predicted_price, 1, upper_bound, [], [], [], [], [], options);

end

