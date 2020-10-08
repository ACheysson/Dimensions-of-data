tolf = 1e-8;

tet_a = 4;
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

% have them rewritten
t_sig = [q_a, q_b];
t_s = [q_a*sig_ab/var_tet_a, q_b*sig_ab/var_tet_b];

% Useful shortcuts
alpha = (1-gamma)/(1-2*gamma);
beta = alpha - 1;
param = gamma/(2*(1-gamma));
% Also param = beta/(2*alpha)

% We posit a Nash Equilibrium of the form:
% p_i = A_i + B_i*(s_i - sig_i)

% We wrote the demand functions as:
% q_a = alpha*tet_a - beta*tet_b - alpha*p_a + beta*p_b
% q_b = -beta*tet_a + alpha*tet_b + beta*p_a - alpha*p_b
%

% We want to solve a system of 6 variables and 6 equations, use matrix form
B        = [tet_a/2 - param*tet_b;
            tet_b/2 - param*tet_a;
            t_sig(1) - t_s(1)*param;
            t_sig(2) - t_s(2)*param];
       
% Variables are A_a, A_b, B_a, B_b, C_a, C_b
A =        [-1, param, 0, 0; ...
            param, -1, 0, 0; ...
            0, 0, -1, param*t_s(1); ...
            0, 0, param*t_s(2), -1];
        
% The matrixes are such that A*x + B = 0
sols = linsolve(A, -B);

% Here are the equations written in their direct forms
inter(1) = tet_a/(2*(1-param^2)) - tet_b/2*param/(1-param^2) - (param^2*tet_a)/(1-param^2);
inter(2) = tet_b/(2*(1-param^2)) - tet_a/2*param/(1-param^2) - (param^2*tet_b)/(1-param^2);
inter(3) = (t_sig(1) - t_s(1)*param + param*t_sig(2)*t_s(1) - param^2*t_s(2)*t_s(1))/(1-param^2*t_s(1)*t_s(2)); 
inter(4) = (t_sig(2) - t_s(2)*param + param*t_sig(1)*t_s(2) - param^2*t_s(1)*t_s(2))/(1-param^2*t_s(1)*t_s(2)); 


%% Check that it is indeed a Nash Equilibrium

for s_a = 1:0.1:10
    s_b = s_a;
    % Write the FOC and compare for A
    p_a_foc_t = tet_a/2 + param*inter(2) - param*tet_b + (s_a-tet_a)*(t_sig(1)+param*(inter(4)-1)*t_s(1));
    p_a_pol = inter(1) + inter(3)*(s_a-tet_a);
    
    if abs(p_a_foc_t - p_a_pol) > tolf
        disp('Something is wrong here')
    end
    
    % Write the FOC and compare for B
    p_b_foc_t = tet_b/2 + param*inter(1) - param*tet_a + (s_b-tet_b)*(t_sig(2)+param*(inter(3)-1)*t_s(2));
    p_b_pol = inter(2) + inter(4)*(s_b-tet_b);
    
    if abs(p_b_foc_t - p_b_pol) > tolf
        disp('Something is wrong here')
    end
end


q_a_v = 1:0.1:20;
vec_a = zeros(length(q_a_v),2);
vec_b = zeros(length(q_a_v),2);
for ii = 1:length(q_a_v)
    q_a = q_a_v(ii);
    % First need to find the policy function
    t_sig = [var_tet_a/(var_tet_a + 1/q_a), var_tet_b/(var_tet_b + 1/q_b)];
    t_s = [sig_ab/(var_tet_a + 1/q_a), sig_ab/(var_tet_b + 1/q_b)];
    % Check the intercept
    vec_a(ii,1) = tet_a/(2*(1-param^2)) - tet_b/2*param/(1-param^2) - (param^2*tet_a)/(1-param^2);
    vec_a(ii,2) = tet_b/(2*(1-param^2)) - tet_a/2*param/(1-param^2) - (param^2*tet_b)/(1-param^2);
    
    % Check the part that depends on the signal deviation
    vec_b(ii,1) = (t_sig(1) - t_s(1)*param + param*t_sig(2)*t_s(1) - param^2*t_s(2)*t_s(1))/(1-param^2*t_s(1)*t_s(2)); 
    vec_b(ii,2) = (t_sig(2) - t_s(2)*param + param*t_sig(1)*t_s(2) - param^2*t_s(1)*t_s(2))/(1-param^2*t_s(1)*t_s(2)); 
end
