% This implements the simple nash equilibrium of the Cournot game
tolf = 1e-8;

tet_a = 2;
tet_b = 2;
gamma = 0.45;

% Write variances
var_tet_a = 1;
var_tet_b = 1;
sig_ab = -0.5;

% For now take as given first period values of q (only matters for precision of signal)
q_a = 3;
q_b = 3;

% First need to find the policy function
t_sig = [var_tet_a/(var_tet_a + 1/q_a), var_tet_b/(var_tet_b + 1/q_b)];
t_s = [sig_ab/(var_tet_a + 1/q_a), sig_ab/(var_tet_b + 1/q_b)];

param = gamma/(2*(1-gamma));

% We want to solve a system of 6 variables and 6 equations, use matrix form
B        = [tet_a/(2*(1-gamma)); ...
            tet_b/(2*(1-gamma)); ...
            t_sig(1)/(2*(1-gamma)); ...
            t_sig(2)/(2*(1-gamma))];
       
% Variables are A_a, A_b, B_a, B_b, C_a, C_b
A =        [-1, -param, 0, 0; ...
            -param, -1, 0, 0; ...
            0, 0, -1, -param*t_s(1); ...
            0, 0, -param*t_s(2), -1];
        
% The matrixes are such that A*x + B = 0
sols = linsolve(A, -B);

% Explictly written formulas
inter = zeros(4,1);
inter(1) = (tet_a/(2*(1-gamma)) - param*tet_b/(2*(1-gamma)))/(1-param^2);
inter(2) = (tet_b/(2*(1-gamma)) - param*tet_a/(2*(1-gamma)))/(1-param^2);
inter(3) = (t_sig(1)/(2*(1-gamma)) - param*t_s(1)*t_sig(2)/(2*(1-gamma)))/(1 - param^2*t_s(1)*t_s(2));
inter(4) = (t_sig(2)/(2*(1-gamma)) - param*t_s(2)*t_sig(1)/(2*(1-gamma)))/(1 - param^2*t_s(2)*t_s(1));



