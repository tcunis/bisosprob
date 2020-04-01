# `BiSOSprob` : Toolbox for bilinear sum-of-squares problems

This is a collection of development-in-progress tools for the definition and solution of bilinear sum-of-squares problems in a generic manner. As of today, it allows the specification of bilinear problems in terms of polynomial decision variables (rather than their coefficients) and the design, visualization, and automated execution of iteration schemes in order to solve those problems efficiently. Many desirable features are still under development and have not yet been implemented.

Note: `BiSOSprob` is **not** a sum-of-squares solver itself; rather, it makes use of the [`sosfactory`](https://github.com/tcunis/sosfactory) interface to connect to various openly available sum-of-squares toolboxes, such as sosopt or SPOT, which need to be downloaded and installed separately.
