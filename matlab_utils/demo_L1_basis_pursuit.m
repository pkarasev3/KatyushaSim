% suggested in: 
% OPTIMIZATION TECHNIQUES FOR SOLVING
% BASIS PURSUIT PROBLEMS
% By
% Kristen Michelle Cheman
% A Thesis Submitted to the Graduate
% Faculty of North Carolina State University
% in Partial Fulﬁllment of the
% Requirements for the Degree of
% MASTER OF APPLIED MATHEMATICS

% PK test: random underdetermined problem
% let's chase down and curb a basis
A = randn(4,5); 
b = randn(4,1);

% x :- desired sparse solution

% support :- support set for vector x

% lsupport :- cardinality of the support set

[m,n] = size(A);

Amatrix = [A' 2*eye(n)];

bvector = ones(n,1);

cvector = [-b; zeros(n,1)];

lb = [-inf*ones(m,1); zeros(n,1)];

ub = [inf*ones(m,1); ones(n,1)];

% track the time required to solve the dual problem

profile on

[primal,obj,exitflag,output,dual] = linprog(cvector,[],[],Amatrix,bvector,lb,ub);

profile viewer

% x is the dual variable corresponding to the equality constraints in dual problem

xL1 = dual.eqlin

% Let us compute the support set of x

support = find(abs(xL1)/max([1 normest(A) norm(b)]) > 1e-8)

% Compute the cardinality of the support set

lsupport = length(support)

lambda = 1e-6;
xL2 = A' *( ( A * A' ) \ b )
