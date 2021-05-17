# `BiSOS` : Toolbox for bilinear sum-of-squares problems

This is a collection of development-in-progress tools for the definition and solution of bilinear sum-of-squares problems in a generic manner. As of today, it allows the specification of bilinear problems in terms of polynomial decision variables (rather than their coefficients) and the design, visualization, and automated execution of iteration schemes in order to solve those problems efficiently. Many desirable features are still under development and have not yet been implemented.

Note: `BiSOSprob` is **not** a sum-of-squares solver itself; rather, it makes use of the [`sosfactory`](https://github.com/tcunis/sosfactory) interface to connect to various openly available sum-of-squares toolboxes, such as sosopt or SPOT, which need to be downloaded and installed separately.

## Defining bilinear SOS problems: the class [`bisosprob`](https://github.com/tcunis/bisosprob/blob/master/%40bisosprob/bisosprob.m)

In the `BiSOS` toolbox, bilinear SOS problems are defined in a similar manner to conventional, convex SOS problems. First, we need to declare the independent variables (e.g., system states) of our polynomials and any problem data. `BiSOS` relies on the `sosfactory` toolbox to be independent of the available implementations; in this [example](https://github.com/tcunis/bisosprob/blob/master/demo.m) we are going to use the factory methods for `sosopt`:

```
import sosfactory.sosopt.*

sosf = SosoptFactory;

x = polyvar(sosf,'x',2,1);

f = [x(2); -(1-x(1)^2)*x(2) - x(1)];

% Jacobian matrix
J = sosf.jacob(f,x);

% polynomial shape
p = x'*x;

% epsilon polynomial
l = x'*x*1e-6;
```

We have declared a variable `x` of length 2 and the system dynamics `f` as Van der Pol oscillator with negative damping factor, computed the Jacobian matrix of `f`, and defined a polynomial shape `p` and small polynomial `l`, for we want to estimte the region of attraction of our system.

Next, we create a new problem supplying the SOS factory we want to use (`sosf`) and the vector of independent variables `x`:
```
prob = bisosprob(sosf,x);
```

### Decision variables
Unlike convex SOS solver, `BiSOS` expects the decision variables to be polynomial objects rather than the actual coefficients of these polynomials. However, we still need decision variables to be of finite dimension. To this extent, for each decision we have to define a subset of finite dimension in form of a vector of monomials:

```
% Lyapunov candidate
[prob,V] = polydecvar(prob,'V',[x(1)^2; x(1)*x(2); x(2)^2]);

% SOS multipliers
[prob,s1] = sosdecvar(prob,'s1',monomials(x,0));
[prob,s2] = sosdecvar(prob,'s2',monomials(x,1:2));

% level sets
[prob,g] = decvar(prob,'g');
[prob,b] = decvar(prob,'b');
```

Similar to other toolboxes, `BiSOS` supports polynomial, sum-of-squares, and scalar and matrix decision variables:
- Polynomial decision variables (`polydecvar(prob, var, w)`) a variables of the form `p ∈ {Q⋅w | Q ∈ ℝ^(1×l)}`, where `l` is the length of the vector of monomials `w`;
- Sum-of-squares decision variables (`sosdecvar(prob, var, z)`) a variables of the form `s ∈ {z'⋅Q⋅z | Q ∈ ℝ^(l×l) symmetric}`;
- Scalar and matrix decision variables (`decvar(prob, var)`) are variables of the form `a ∈ ℝ`.

In addition to decision variables, we can define subsidary variables defined by functions *in* the decision variables, which are difficult or impossible to compute by basic mathematical operations.

```
[prob,gradV] = substitute(prob,'dV',@(p) sosf.jacob(p,x),{'V'});
```

The syntax `substitute(prob, var, fhan, lvar, args)` registers a new variable defined by the function `fhan(lvar1,...,lvarM,args1,...,argsN)`. The function handle `fhan` must be linear in the variables (coefficients) of `lvar`. Additional, nonlinear inputs can be specified as `args`. 

### Constraints
One the main features of this toolbox is to define the constraints once, independently from the solution approach. `BiSOS` supports non-strict inequality and equality constraints (in a sum-of-squares sense):

```
% Stable level set
prob = le(prob, gradV*f + l, s2*(V-g), {'dV'}, {'V' 'g' 's2'});
prob = ge(prob, s2, 0, {'s2'});
prob = ge(prob, V, l, {'V'});

% Inscribing ellipsoid
prob = le(prob, V - g, s1*(p-b), {'V' 'g'}, {'b' 's1'});
prob = ge(prob, s1, 0, {'s1'});
```

The syntax `le(prob, lhs, rhs, lvar, bvar)` and `ge(prob, lhs, rhs, lvar, bvar)` registers the constraints `rhs - lhs is SOS` and `lhs - rhs is SOS`, respectively. The syntax `eq(prob, lhs, rhs, lvar, bvar)` registers the constraint `lhs == rhs`. The realisation of these constraints depends on the used SOS toolbox. The additional parameters `lvar` and `bvar` specify the list of variables in which both left and right-hand side are linear and bilinear, respectively. If a decision variable enters both linearily *and* bilinearily into a constraint, it should be declared as bilinear only.

### Initial values & Objective function
Solving bilinear SOS problems, for example with iterative approaches, often requires initial values for some of the decision variables:

```
% linearization around origin
J0 = double(subs(J,x,zeros(2,1)));

% solve Lyapunov equation
P = lyap(J0',eye(2));

prob = setinitial(prob,'V',x'*P*x);
```

Initial values can also be provided directly when declaring a decision variable, e.g., `[prob,b] = decvar(prob,'b',0)`.

The objective function of a bilinear SOS problem is set similarly:

```
prob = setobjective(prob, -b, {'b'});
```

The objective function must be linear in the decision variables.

## Solving bilinear SOS problems: the class [`bisos.Iteration`](https://github.com/tcunis/bisosprob/blob/master/%2Bbisos/%40Iteration/Iteration.m)

### Visualization
`BiSOS` provides visualization of the bilinear problems as undirected graphs, where the nodes represent variables, initial values, and the objective; and edges between nodes represent a constraint that involves both variables (liner or bilinear) or a substitution; an edge between a node with itself represents a constraint in a single variable.

![Graph of the exemplary `BiSOS` problem](https://github.com/tcunis/bisosprob/raw/master/figures/demo-prob.png)
