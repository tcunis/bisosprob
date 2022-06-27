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
- The syntax `polydecvar(prob, var, w)` registers a polynomial decision variable `var` of the form `p ∈ {Q⋅w | Q ∈ ℝ^(1×l)}`, where `l` is the length of the vector of monomials `w`;
- The syntax `sosdecvar(prob, var, z)` registers a sum-of-squares decision variable `var` of the form `s ∈ {z'⋅Q⋅z | Q ∈ ℝ^(l×l) symmetric}` with vector of monomials `z`;
- The syntax `decvar(prob, var, [n m])` registers a matrix decision variable `var` of the form `a ∈ ℝ^(n×m)`; if the size argument is omitted, then `n = m = 1`.

In addition to decision variables, we can define subsidary variables defined by functions *in* the decision variables, e.g., by mathematical operators such as differentiation or definite integration.

```
[prob,gradV] = substitute(prob,'dV',@(p) sosf.jacob(p,x),{'V'});
```

The syntax `substitute(prob, var, fhan, lvar, args)` registers a new variable defined by the function `fhan(lvar1,...,lvarM,args1,...,argsN)`, where `lvar = {lvar1,...,lvarM}` and `args = {args1,...,argsN}`. The function handle `fhan` must be linear in the variables (coefficients) of `lvar`. Additional, nonlinear inputs can be specified as `args`. 

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

A common approach for bilinear SOS problems are iterative bisections. For example, a constraint `a(x)*b(x) is SOS` can be bisected by solving for an optimal `a` given a solution `b`, then using the optimal `a` to solve for `b`, and repeat. Indeed, such an approach requires an initial solutions for either `a` or `b`.
The region-of-attraction estimation problem given above is classically solved with a "V-s-iteration" with three distinct steps, solving respectively for `g`, `b`, and `V`.

`BiSOS` provides a class in order to define and run bespoken iterative bisection schemes for a given bilinear SOS problem:

```
% define iteration
iter = bisos.Iteration(prob);
```

Iterations are defined by registering optimization steps; optional output steps allow for user interaction (described [next](https://github.com/tcunis/bisosprob#steps)). `BiSOS` can suggest the order in which steps are executed in each iteration, or run steps in the order of registration or separately given by the user (see [Routing](https://github.com/tcunis/bisosprob#routing)). A class of [Options](https://github.com/tcunis/bisosprob#options) adds further customization.

### Steps
The following types of steps are available for iterations:

**Pre-defined steps: Initialization and objective** -
Each iteration has an initialization and an objective step, which are pre-defined by the bilinear SOS problem. They are automatically registered and cannot be customized.

**Optimization steps: Convex and quasi-convex** -
At the core of each iteration, convex optimization steps and/or quasi-convex bisection steps can be registered by defining the free decision variables and, optionally, an auxiliary objective. `BiSOS` then automatically detects which constraints are involved in the optimization steps and which decision variables need to be fixed.

```
iter = iter.addconvex({'V'});
```

The syntax `addconvex(iter, lvar, obj, ovar)` registers a convex minimization step with free decision variables `lvar` and the objective `obj` defined in the variables `ovar`. In the example, a feasibility step (without objective) for `V` is added.

```
iter = iter.addbisect({'s1'},-b,{'b'});
```

*Quasi-convex optimization* is a SOS problem which is convex except for a single, *scalar* decision variable that enters bilinearily into the constraint and which is optimized for. Such problems can be solved using a binary search approach which is efficiently implemented in some SOS toolboxes. Here, the syntax `addbisect(iter, lvar, obj, ovar)` registers a quasi-convex bisection of the decision variables `lvar` along the scalar objective variable `ovar` and with the objective `obj`. Unlike convex optimization steps, the objective **must** be decision variable, either positive or negative, which is *not* a free decision variable.

```
iter = iter.addbisect({'s2'},-g,{'g'},{'s1'});
```

Sometimes, `BiSOS` might identify some constraints as being involved in the optimization step which the user has determined to hold trivially. Such constraints can be excluded from the optimization step by the optional syntax `addconvex(..., excl)` or `addbisect(..., excl)` where `excl` is a list of decision variables disjunct from `lvar` or `ovar`; any constraint with an excluded variable is omitted from the optimization step.

**Termination step: Convergence and termination rule** -
The user can add a convergence supervision of a certain set-level, this is evaluated by the integral of the norm of the difference between the previous normalized polynomial and the current over a certain domain (hypercube). Two properties can be setup such as tolerance and the domain of integration. Default: `ctol = 10^-9` and `domain = [-1 1]`.

```
iter = iter.addconvergence({'V' 'g'}, {'ctol', Value1, 'domain', [xmin xmax]});
```

The algorithm cycle can be automatically terminated when a certain rule isn't followed, for example, over each cycle the value `'b'` must always increase and whenever it doesn't the cycle must stop. The step defition has 3 inputs: `previous`, `current` and `operator` (`OP`), meaning that the algorithm will continue except when the condition '`previous OP current`' is violated.  

```
ter = iter.addtermination({var1}, {var2}, operator);
```

A more generalized and complex termination rule can also be setup with the same step initialization using function handles.


```
iter = iter.addtermination({ func_handle1, vars1,... ,varsN },{func_handle2 , vars1,... ,varsM }, operator);
```


**Output steps: Messages and arbitrary output functions** -
Outputs for each iteration add extended possibilities for user supervision and interaction. Currently supported are formatted messages printed to the stream (see `Options.fid`) and custom output function handels.

```
iter = iter.addmessage('gamma = %f,\t beta = %f\n',{'g' 'b'});
```

The syntax `addmessage(iter, fmt, vars)` registers a message formatter `fmt` for the decision variables `vars`. Only scalar variables can be printed. The optional syntax `addmessage(..., lvl)` sets the display level of the message (cf. `Options.display`); the default is `'step'`.

```
iter = iter.addoutputfcn(@plot_sol,{'V' 'g' 'b'},p);
```

The syntax `addoutputfcn(iter, fhan, vars, varargin)` registers a output function `fhan(vars1,...,varsM,varargin)` in the decision variables `vars = {vars1,...,varsM}`. Additional parameters are forwarded to the output function.

### Routing & Running
The built-in *routing* algorithm determines a suitable order in which to execute the registered steps. The routing is represented by a directional graph: The syntax `G = route(iter)` returns a [digraph](https://mathworks.com/help/matlab/ref/digraph.html) object `G` for inspection, e.g.,

```
plot(G,'Layout','layered')
```

(see the [reference](https://mathworks.com/help/matlab/ref/graph.plot.html) for more information on graph visualization). The digraph object `G` can also be modified by changing edges and adding empty nodes, and provided as optional argument when executing the iteration:

```
sol = run(iter, G);
```

**N.B.**: The initialization node is always the first step to be executed in each iteration. Every node should have at least one predecessor and one successor, representing inter-dependencies between steps. During on iteration, a step is only executed once all its predecessors have been executed; the order in which multiple successors are executed, however, is undetermined and possibly allows for future parallelization. The last node in the order must loop back to the initialization. As of now, *the ordering graph is **not** checked for consistency.*

The syntax `sol = run(iter, ...)` returns the solution structure `sol`. If no ordering digraph is provided, `BiSOS` determines the order of steps (cf. also `Options.routing`). 

### Options

`BiSOS` has a number of options for iterations, which are provided using either (or both) of two ways:

1. Appending a list of name-value pairs to when instantiating the iteration using the syntax `iter = bisos.Iteration(iter, 'Name1',Value1, 'Name2',Value2, ...)`.
2. Assigning values to the fields of the iteration's `options` object as per `iter.options.('Name1') = Value1`, or equivalently, using the syntax `iter = setfield(iter, 'Name2', Value2)`.

The following options and possible values are implemented:

#### List of options

`Options.Niter` determines the number of iterations to be performed; must be a positive integer. Default: `Options.Niter = 10`.

`Options.display` sets the level of messages (pre-implemented or user-defined) that are displayed: `'off'` - display no messages; `'result'` - display only messages about the results; `'warning'` - also display warnings; `'step'` - display messages for each iteration as well as warnings; `'debug'` - also display additional messages. Default: `Options.display = 'off'`.

`Options.routing` handles routing if no ordering graph is provided: `'auto'` - determine order of steps by automatic routing; `'user'` execute steps in order of registration by the user. Default: `Options.routing = 'auto'`.

`Options.savesol` writes the solution structure to file: `'off'` - don't save solutions; `'result'` - save the resulting solution; `'step'` - save solutions of each iteration. Default: `Options.savesol = 'off'`.

`Options.logname`, if given, specifies the name of the log file into which messages are written. The log file is created if non-existent and cleared of any data at the begin of the iteration. Default: `Options.logname = []`.

`Options.logdir` names the directory for log file and/or saved solution structures. The log directory is created if non-existent and cleared of any `mat`-files at the begin of the iteration. Default: `Options.logdir = '.'`.

`Options.logprefix` sets a file name prefix for log file and/or save solution structures. Default: `Options.logprefix = ''`.

`Options.fid` determines the file handle to which messages are printed. Possible values are `1` - Matlab standard output; `2` - Matlab error output; a positive integer `> 2`, provided the file exists. Default: `Options.fid = 1`.

The options `logname` and `fid` should not be used simultaneously. Simply speaking, `Options.logname` is a short-hand for

```
Options.fid = fopen([logdir '/' logprefix logname], 'w');
```

`Options.sosoptions` provides a toolbox-dependent options structure that is forwarded to the respective SOS optimization toolbox.


## Visualization
`BiSOS` provides visualization of the bilinear problems as undirected graphs, where the nodes represent variables, initial values, and the objective; and edges between nodes represent a constraint that involves both variables (linear or bilinear) or a substitution; an edge between a node with itself represents a constraint in a single variable.

![Graph of the exemplary `BiSOS` problem](https://github.com/tcunis/bisosprob/raw/master/figures/demo-prob.png)
