% Deep parameters of the model
tet_a = 2;
tet_b = 1.8;
gamma = 0.25;

% Write variances
var_tet_a = 1;
var_tet_b = 1.2;
sig_ab = -0.5;

% For now take as given first period values of q (only matters for precision of signal)
q_a = 3;
q_b = 2;

% First need to find the policy function
t_sig = [var_tet_a/(var_tet_a + 1/q_a), var_tet_b/(var_tet_b + 1/q_b)];
t_s = [sig_ab/(var_tet_a + 1/q_a), sig_ab/(var_tet_b + 1/q_b)];

% We want to solve a system of 6 variables and 6 equations, use matrix form
B        = [1-t_sig(1) + gamma/(1-gamma) * t_s(1); ... % equation 1
            1-t_sig(2) + gamma/(1-gamma) * t_s(2); ... % equation 2
            -gamma/(1-gamma); ...
            -gamma/(1-gamma); ...
            t_sig(1) - gamma/(1-gamma) * (t_s(1)); ...
            t_sig(2) - gamma/(1-gamma) * (t_s(2))]/2;
       
% Variables are A_a, A_b, B_a, B_b, C_a, C_b
A =        [-1, gamma/(2*(1-gamma)), 0, 0, 0, -gamma/(1-gamma)*t_s(1)/2; ...
            gamma/(2*(1-gamma)), -1, 0, 0, -gamma/(1-gamma)*t_s(2)/2, 0; ...
            0, 0, -1, gamma/(2*(1-gamma)), 0, gamma/(2*(1-gamma)); ...
            0, 0, gamma/(2*(1-gamma)), -1, gamma/2*((1-gamma)), 0; ...
            0, 0, 0, 0, -1, gamma/(2*(1-gamma))*t_s(1); ...
            0, 0, 0, 0, gamma/(1-gamma)*t_s(2)/2, -1];
        
% The matrixes are such that A*x + B = 0
sols = linsolve(A, -B);

for s_a = -1:0.1:1
    % Now that we have the solutions we must compute from the FOC to check
    p_a = (tet_a + t_sig(1)*(s_a - tet_a) - gamma/(1-gamma) * (tet_b + t_s(1)*(s_a - tet_a)) + ...
                                            gamma/(1-gamma)*sols(6) * (tet_b + t_s(1)*(s_a -tet_a)) + ...
                                            gamma/(1-gamma)*sols(2)*tet_a + ...
                                            gamma/(1-gamma)*sols(4)*tet_b)/2;
    % now given the solutions that we found
    p_a_predict = sols(1)*tet_a + sols(3)*tet_b + sols(5)*s_a;

end

GAM = (gamma/(1-gamma));

C_a = (GAM*t_s(1)*(t_sig(2)/2 - GAM*t_s(2)/2 - 1) + t_sig(1))/(2-GAM^2*t_s(1)*t_s(2)/2);
C_b = (GAM*t_s(2)*(t_sig(1)/2 - GAM*t_s(1)/2 - 1) + t_sig(2))/(2-GAM^2*t_s(2)*t_s(1)/2);
