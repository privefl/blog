---
title: "Choosing hyper-parameters in penalized regression"

author: "Florian Privé"
date: "November 23, 2018"
layout: post
---


<section class="main-content">
<p>In this post, I’m evaluating some ways of choosing hyper-parameters (<span class="math inline">\(\alpha\)</span> and <span class="math inline">\(\lambda\)</span>) in penalized linear regression. The same principles can be applied to other types of penalized regresions (e.g. logistic).</p>
<div id="model" class="section level2">
<h2>Model</h2>
<p>In penalized linear regression, we find regression coefficients <span class="math inline">\(\hat{\beta}_0\)</span> and <span class="math inline">\(\hat{\beta}\)</span> that minimize the following regularized loss function <span class="math display">\[L(\lambda, \alpha) = \underbrace{ \frac{1}{2n} \sum_{i=1}^n \left( y_i - \hat{y}_i \right)^2 }_\text{Loss function}   +   \underbrace{ \lambda \left((1-\alpha)\frac{1}{2}\|\hat{\beta}\|_2^2 + \alpha \|\hat{\beta}\|_1\right) }_\text{Penalization} ~,\]</span> where <span class="math inline">\(\hat{y}_i=\hat{\beta}_0 + x_i^T\hat{\beta}\)</span>, <span class="math inline">\(0 \le \alpha \le 1\)</span> and <span class="math inline">\(\lambda &gt; 0\)</span>.</p>
<p>This regularization is called elastic-net and has two particular cases, namely LASSO (<span class="math inline">\(\alpha = 1\)</span>) and ridge (<span class="math inline">\(\alpha = 0\)</span>). So, in elastic-net regularization, hyper-parameter <span class="math inline">\(\alpha\)</span> accounts for the relative importance of the L1 (LASSO) and L2 (ridge) regularizations. There is another hyper-parameter, <span class="math inline">\(\lambda\)</span>, that accounts for the amount of regularization used in the model.</p>
<p>I won’t discuss the benefits of using regularization here.</p>
</div>
<div id="data" class="section level2">
<h2>Data</h2>
<p>In this blog post, I’m using the <a href="http://myweb.uiowa.edu/pbreheny/data/bcTCGA.html">Breast cancer gene expression data from The Cancer Genome Atlas</a>.</p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">dir.create</span>(dir &lt;-<span class="st"> &quot;/tmp/data&quot;</span>, <span class="dt">showWarnings =</span> <span class="ot">FALSE</span>)
file &lt;-<span class="st"> </span><span class="kw">file.path</span>(dir, <span class="st">&quot;bcTCGA.rds&quot;</span>)
<span class="cf">if</span> (<span class="op">!</span><span class="kw">file.exists</span>(file)) {
  <span class="kw">download.file</span>(<span class="st">&quot;https://s3.amazonaws.com/pbreheny-data-sets/bcTCGA.rds&quot;</span>,
                <span class="dt">destfile =</span> file)
}
bcTCGA &lt;-<span class="st"> </span><span class="kw">readRDS</span>(file)</code></pre></div>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">X &lt;-<span class="st"> </span>bcTCGA<span class="op">$</span>X
<span class="kw">dim</span>(X)</code></pre></div>
<pre><code>## [1]   536 17322</code></pre>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">X[<span class="dv">1</span><span class="op">:</span><span class="dv">5</span>, <span class="dv">1</span><span class="op">:</span><span class="dv">5</span>]</code></pre></div>
<pre><code>##        15E1.2     2&#39;-PDE     7A5       A1BG      A2BP1
## [1,] -1.44775  0.0153750  2.4105  0.9493333  0.5391667
## [2,] -2.29950  0.4669375  0.3635  0.2798333 -1.5346667
## [3,] -1.94400 -0.0295625  1.8550  0.7486667 -1.3048333
## [4,] -2.09800  0.7919375  1.4080  0.7500000 -1.3578333
## [5,] -1.28500 -0.1911250 -1.3005 -0.5471667 -2.1845000</code></pre>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">y &lt;-<span class="st"> </span>bcTCGA<span class="op">$</span>y
<span class="kw">hist</span>(y)</code></pre></div>
<p><img src="{{ site.url }}{{ site.baseurl }}/knitr_files/post-glmnet_files/figure-html/unnamed-chunk-2-1.png" style="display: block; margin: auto;" /></p>
</div>
<div id="methods-compared" class="section level2">
<h2>Methods compared</h2>
<p>I’m comparing 6 different estimations of <span class="math inline">\(y\)</span> with the following code. I’m explaining what are these estimations after the code.</p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">timing &lt;-<span class="st"> </span><span class="cf">function</span>(expr) <span class="kw">system.time</span>(expr)[<span class="dv">3</span>]

RMSE &lt;-<span class="st"> </span><span class="cf">function</span>(pred, y.test) {
  <span class="kw">stopifnot</span>(<span class="kw">length</span>(pred) <span class="op">==</span><span class="st"> </span><span class="kw">length</span>(y.test))
  <span class="kw">mean</span>((pred <span class="op">-</span><span class="st"> </span>y.test)<span class="op">^</span><span class="dv">2</span>)
}

<span class="kw">set.seed</span>(<span class="dv">1</span>)
<span class="co"># !! 5h of computations on my computer !! </span>
res_all &lt;-<span class="st"> </span><span class="kw">replicate</span>(<span class="dv">200</span>, <span class="dt">simplify =</span> <span class="ot">FALSE</span>, {

  ind.train &lt;-<span class="st"> </span><span class="kw">sample</span>(<span class="kw">nrow</span>(X), <span class="dv">400</span>)
  ind.test  &lt;-<span class="st"> </span><span class="kw">setdiff</span>(<span class="dv">1</span><span class="op">:</span><span class="kw">nrow</span>(X), ind.train)

  <span class="kw">library</span>(glmnet)
  t_all &lt;-<span class="st"> </span><span class="kw">timing</span>(mod_all &lt;-<span class="st"> </span><span class="kw">glmnet</span>(X[ind.train, ], y[ind.train]))
  preds_all &lt;-<span class="st"> </span><span class="kw">predict</span>(mod_all, X[ind.test, ])
  rmse_all &lt;-<span class="st"> </span><span class="kw">apply</span>(preds_all, <span class="dv">2</span>, RMSE, y[ind.test])

  t_cv &lt;-<span class="st"> </span><span class="kw">timing</span>(mod_cv &lt;-<span class="st"> </span><span class="kw">cv.glmnet</span>(X[ind.train, ], y[ind.train]))
  preds_1se &lt;-<span class="st"> </span><span class="kw">predict</span>(mod_cv, X[ind.test, ], <span class="dt">s =</span> <span class="st">&quot;lambda.1se&quot;</span>)
  rmse_1se &lt;-<span class="st"> </span><span class="kw">RMSE</span>(preds_1se, y[ind.test])
  preds_min &lt;-<span class="st"> </span><span class="kw">predict</span>(mod_cv, X[ind.test, ], <span class="dt">s =</span> <span class="st">&quot;lambda.min&quot;</span>)
  rmse_min &lt;-<span class="st"> </span><span class="kw">RMSE</span>(preds_min, y[ind.test])

  <span class="kw">library</span>(bigstatsr)
  t_CMSA &lt;-<span class="st"> </span><span class="kw">timing</span>({
    X2 &lt;-<span class="st"> </span><span class="kw">as_FBM</span>(X)
    mod_CMSA &lt;-<span class="st"> </span><span class="kw">big_spLinReg</span>(X2, y[ind.train], ind.train)
  })
  preds_CMSA &lt;-<span class="st"> </span><span class="kw">predict</span>(mod_CMSA, X2, ind.test)
  rmse_CMSA &lt;-<span class="st"> </span><span class="kw">RMSE</span>(preds_CMSA, y[ind.test])

  <span class="kw">library</span>(glmnetUtils)
  ALPHA &lt;-<span class="st"> </span><span class="kw">c</span>(<span class="dv">1</span>, <span class="fl">0.5</span>, <span class="fl">0.1</span>)
  t_cva &lt;-<span class="st"> </span><span class="kw">timing</span>(mod_cva &lt;-<span class="st"> </span><span class="kw">cva.glmnet</span>(X[ind.train, ], y[ind.train], <span class="dt">alpha =</span> ALPHA))
  alpha &lt;-<span class="st"> </span>ALPHA[<span class="kw">which.min</span>(<span class="kw">sapply</span>(mod_cva<span class="op">$</span>modlist, <span class="cf">function</span>(mod) <span class="kw">min</span>(mod<span class="op">$</span>cvm)))]
  rmse_cva &lt;-<span class="st"> </span><span class="kw">RMSE</span>(<span class="kw">predict</span>(mod_cva, X[ind.test, ], <span class="dt">alpha =</span> alpha), y[ind.test])

  t_CMSA2 &lt;-<span class="st"> </span><span class="kw">timing</span>({
    X2 &lt;-<span class="st"> </span><span class="kw">as_FBM</span>(X)
    mod_CMSA2 &lt;-<span class="st"> </span><span class="kw">big_spLinReg</span>(X2, y[ind.train], ind.train, <span class="dt">alphas =</span> ALPHA)
  })
  preds_CMSA2 &lt;-<span class="st"> </span><span class="kw">predict</span>(mod_CMSA2, X2, ind.test)
  rmse_CMSA2 &lt;-<span class="st"> </span><span class="kw">RMSE</span>(preds_CMSA2, y[ind.test])

  tibble<span class="op">::</span><span class="kw">tribble</span>(
    <span class="op">~</span>method,        <span class="op">~</span>timing,  <span class="op">~</span>rmse,
    <span class="st">&quot;glmnet_best&quot;</span>,  t_all,    <span class="kw">min</span>(rmse_all),
    <span class="st">&quot;glmnet_min&quot;</span>,   t_cv,     rmse_1se,
    <span class="st">&quot;glmnet_1se&quot;</span>,   t_cv,     rmse_min,
    <span class="st">&quot;CMSA&quot;</span>,         t_CMSA,   rmse_CMSA,
    <span class="st">&quot;glmnet_cva&quot;</span>,   t_cva,    rmse_cva,
    <span class="st">&quot;CMSA2&quot;</span>,        t_CMSA2,  rmse_CMSA2
  )

})

res &lt;-<span class="st"> </span><span class="kw">do.call</span>(rbind, res_all)
res<span class="op">$</span>run_number &lt;-<span class="st"> </span><span class="kw">rep</span>(<span class="kw">seq_along</span>(res_all), <span class="dt">each =</span> <span class="dv">6</span>)</code></pre></div>
<p>The methods compared are:</p>
<ul>
<li><strong>glmnet_best</strong>: the best prediction (on the test set) among all 100 different <span class="math inline">\(\lambda\)</span> values (using <span class="math inline">\(\alpha = 1\)</span>). This is an upper bound of predictive performance using package {glmnet} with L1 regularization.</li>
<li><strong>glmnet_min</strong>: the prediction corresponding to the <span class="math inline">\(\lambda\)</span> that minimizes the error of cross-validation.</li>
<li><strong>glmnet_1se</strong>: similar to <strong>glmnet_min</strong>, but a little more regularized (the maximum regularization whose error of cross-validation is only one standard error away from the minimum).</li>
<li><strong>CMSA</strong>: using cross-model selection and averaging (CMSA, explained in the next session) to “choose” <span class="math inline">\(\lambda\)</span>.</li>
<li><strong>glmnet_cva</strong>: using cross-validation of glmnet on both <span class="math inline">\(\lambda\)</span> AND <span class="math inline">\(\alpha\)</span>. Using <code>&quot;lambda.1se&quot;</code> (the default) and <span class="math inline">\(\alpha\)</span> that minimizes the error of cross-validation.</li>
<li><strong>CMSA2</strong>: using cross-model selection and averaging (CMSA, explained in the next session) to “choose” <span class="math inline">\(\lambda\)</span> AND <span class="math inline">\(\alpha\)</span>.</li>
</ul>
</div>
<div id="cross-model-selection-and-averaging-cmsa" class="section level2">
<h2>Cross-Model Selection and Averaging (CMSA)</h2>
<p><strong>Source:</strong> <a href="https://doi.org/10.1101/403337" class="uri">https://doi.org/10.1101/403337</a></p>
<p><img src="{{ site.url }}{{ site.baseurl }}/images/simple-CMSA.png" width="80%" style="display: block; margin: auto;" /></p>
<p>Illustration of one turn of the Cross-Model Selection and Averaging (CMSA) procedure. First, this procedure separates the training set in <span class="math inline">\(K\)</span> folds (e.g. 10 folds). Secondly, in turn, each fold is considered as an inner validation set (red) and the other (<span class="math inline">\(K - 1\)</span>) folds form an inner training set (blue). A “regularization path” of models is trained on the inner training set and the corresponding predictions (scores) for the inner validation set are computed. The model that minimizes the loss on the inner validation set is selected. Finally, the <span class="math inline">\(K\)</span> resulting models are averaged. We also use this procedure to derive an early stopping criterion so that the algorithm does not need to evaluate the whole regularization paths, making this procedure much faster.</p>
</div>
<div id="results" class="section level2">
<h2>Results</h2>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">library</span>(dplyr, <span class="dt">warn.conflicts =</span> <span class="ot">FALSE</span>)

res <span class="op">%&gt;%</span>
<span class="st">  </span><span class="kw">group_by</span>(method) <span class="op">%&gt;%</span>
<span class="st">  </span><span class="kw">summarise_at</span>(<span class="kw">c</span>(<span class="st">&quot;rmse&quot;</span>, <span class="st">&quot;timing&quot;</span>), mean) <span class="op">%&gt;%</span>
<span class="st">  </span><span class="kw">arrange</span>(rmse)</code></pre></div>
<pre><code>## # A tibble: 6 x 3
##   method       rmse timing
##   &lt;chr&gt;       &lt;dbl&gt;  &lt;dbl&gt;
## 1 glmnet_best 0.208   1.15
## 2 CMSA        0.212   1.18
## 3 CMSA2       0.213   3.98
## 4 glmnet_1se  0.215  12.0 
## 5 glmnet_cva  0.240  35.7 
## 6 glmnet_min  0.240  12.0</code></pre>
<p>So, basically both CMSA from {bigstatsr} and choosing “lambda.1se” from standard cross-validation using {glmnet} provide near-optimal results (0.215 and 0.212 vs 0.208). Yet, CMSA is much faster than cross-validation (due to early stopping).</p>
<p>We also see that using “lambda.1se” performs better than using “lambda.min” for this example, which is confirming what I have seen and read before.</p>
<p>Finally, we see that testing two other values of <span class="math inline">\(\alpha\)</span> (0.5 and 0.1 in addition to 1) does not improve predictive performance for this example (0.213 vs 0.212 for CMSA and 0.240 vs 0.215 for cross-validation using {glmnet}).</p>
</div>
<div id="conclusion" class="section level2">
<h2>Conclusion</h2>
<p>Usually, cross-validation is used to choose hyper-parameter values and then the model is trained again with these particular hyper-parameter values. Yet, performing cross-validation and retraining the model is computationally demanding; CMSA offers a less burdensome alternative, especially because of the early stopping criterion.</p>
<p>Moreover, CMSA doesn’t fit only one model, but instead average over <span class="math inline">\(K\)</span> models, which makes it less noisy (see the last previous results).</p>
<p>Finally, I think CMSA offers a very convenient approach because it is both stable and fast. Moreover, as it is implemented in my package {bigstatsr} that uses filebacked matrices (inspired by packages <a href="https://github.com/kaneplusplus/bigmemory">{bigmemory}</a> and <a href="https://github.com/YaohuiZeng/biglasso">{biglasso}</a>), this algorithm can be run on 100 GB of data. For example, this is what I used for a previous post about <a href="https://privefl.github.io/blog/predicting-height-based-on-dna-mutations/">predicting height based on DNA mutations</a>, using a matrix of size 400K x 560K!</p>
<p>Yet, {bigstatsr} only provides linear and logistic regressions. And it doesn’t implement all the many options supported by {glmnet}. I think it would be of great interest if someone could implement the CMSA procedure for all {glmnet} models and options. Unfortunately, I don’t have time to do it as I need to finish my thesis before next summer.</p>
</div>
</section>
