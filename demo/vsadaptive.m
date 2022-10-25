% Region of attraction estimation for the Van der Pol oscillator.
% V-s iteration with shape function p varying

import sosfactory.sosopt.*

sosf = SosoptFactory;

x = polyvar(sosf,'x',2,1);

f = [x(2); -(1-x(1)^2)*x(2) - x(1)];

% Jacobian matrix
J = sosf.jacob(f,x);

% degree of Lyapunov function
deg = 4;

% epsilon polynomial
l = x'*x*1e-6;

prob = bisosprob(sosf,x);

%% Decision variables
% polynomial shape
% p = x'*x;
[prob,p] = polydecvar(prob,'p',monomials(x,1:2));

% Lyapunov candidate
[prob,V] = polydecvar(prob,'V',monomials(x,1:deg));

% SOS multipliers
[prob,s1] = sosdecvar(prob,'s1',monomials(x,0:deg));
[prob,s2] = sosdecvar(prob,'s2',monomials(x,1:deg));

% level sets
[prob,g] = decvar(prob,'g');
[prob,b] = decvar(prob,'b');

%% Constraints
[prob,gradV] = substitute(prob,'dV',@(p) sosf.jacob(p,x),{'V'});

% Stable level set
prob = le(prob, gradV*f + l, s2*(V-g), {'dV'}, {'V' 'g' 's2'});
prob = ge(prob, s2, 0, {'s2'});
prob = ge(prob, V, 0, {'V'});

% Inscribing ellipsoid
prob = le(prob, V - g, s1*(p-b), {'V' 'g'}, {'b' 's1' 'p'});
prob = ge(prob, s1, 0, {'s1'});

%% Initial Lyapunov-guess
% linearization around origin
J0 = double(subs(J,x,zeros(2,1)));

% solve Lyapunov equation
P = lyap(J0',eye(2));

prob = setinitial(prob,'V',x'*P*x);
prob = setinitial(prob,'p',x'*x);    
% set trivial inscribing shape
% prob = setinitial(prob,'b',0);

%% Solve
prob = setobjective(prob, -b, {'b'});

% define iteration explicitly
iter = bisos.Iteration(prob, 'display','step');
iter = iter.addconvex({'V'});
iter = iter.addbisect({'s1'},-b,{'b'});
iter = iter.addbisect({'s2'},-g,{'g'},{'s1'});
iter = iter.addtransfer({'p'}, @get2degree, {'V'},x);
iter = iter.addmessage('gamma = %f,\t beta = %f\n',{'g' 'b'});
iter = iter.addoutputfcn(@plot_sol,{'V' 'g' 'b' 'p'});

% plot iteration scheme
figure(1)
subplot(1,2,1)
plot(graph(iter),'Layout','layered')

subplot(1,2,2)
plot(route(iter),'Layout','layered')

drawnow

% solve iteration
[sol,info] = run(iter);

disp(sol)

function stop = plot_sol(V,g,b,p)
%% plot solution
figure(2)
clf
pcontour(V, double(g), [-2 2 -2 2], 'b-');
hold on
pcontour(p, double(b), [-2 2 -2 2], 'r--');
drawnow

stop = false;
end

function p = get2degree(V,x)
% return quadratic part of V

[V1,R1] = poly2basis(V, monomials(x,2));

p = R1'*V1;
end
