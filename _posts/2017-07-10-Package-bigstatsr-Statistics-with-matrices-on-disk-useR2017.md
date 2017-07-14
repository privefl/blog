---
title: Package bigstatsr: Statistics with matrices on disk (useR!2017)

author: Florian Privé
date: July 10, 2017
layout: post
---


<section class="main-content">
<p>In this post, I will talk about my package <strong>bigstatsr</strong>, which I’ve just presented in a lightning talk of 5 minutes at useR!2017. You can listen to me in action <a href="https://t.co/aYt0q8MeXJ">there</a>. I should have chosen a longer talk to explain more about this package, maybe next time. I will use this post to give you a more detailed version of the talk I gave last week in Brussels.</p>
<div id="motivation-behind-bigstatsr" class="section level2">
<h2>Motivation behind bigstatsr</h2>
<p>I’m a PhD student in predictive human genetics. I’m basically trying to predict someone’s risk of disease based on their DNA mutations. These DNA mutations are in the form of large matrices so that I’m currently working with a matrix of 15K rows and 300K columns. This matrix would take approximately 32GB of RAM if stored as a standard R matrix.</p>
<p>When I began studying this dataset, I had only 8GB of RAM on my computer. I now have 64GB of RAM but it would take only copying this matrix once to make my computer begin swapping and therefore slowing down. I found a convenient solution by using the object <code>big.matrix</code> provided by the R package <strong>bigmemory</strong> <span class="citation">(Kane, Emerson, and Weston 2013)</span>. With this solution, you can access a matrix that is stored on disk almost as if were a standard R matrix in memory.</p>
<p><img src="https://raw.githubusercontent.com/privefl/useR-2017/master/memory-solution.svg" style="display: block; margin: auto;" /></p>
<p>Yet, some useful statistical functions were missing or not fast enough, for this kind of data. So, I implemented these. It was a good experience about programming optimized and parallelized algorithms. I’m aware that there are other packages that come with <strong>bigmemory</strong>, such as <strong>biganalytics</strong> and <strong>bigalgebra</strong>, that already implement some of the features I will talk about here. I will discuss why I don’t use these packages. However, I use the work of other packages such as <strong>biglasso</strong> and <strong>RSpectra</strong>.</p>
</div>
<div id="introduction-to-bigmemory" class="section level2">
<h2>Introduction to bigmemory</h2>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="co"># loading package bigstatsr (and bigmemory)</span>
<span class="kw">library</span>(bigstatsr)
<span class="co"># initializing some matrix on disk: wrapper to bigmemory::big.matrix()</span>
mat &lt;-<span class="st"> </span><span class="kw">FBM</span>(<span class="dt">backingroot =</span> <span class="st">&quot;matrix-on-disk&quot;</span>, <span class="dt">descriptor =</span> <span class="ot">FALSE</span>)(<span class="fl">5e3</span>, <span class="fl">10e3</span>)</code></pre></div>
<pre><code>## Creating directory &quot;backingfiles&quot; which didn&#39;t exist..</code></pre>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">dim</span>(mat)</code></pre></div>
<pre><code>## [1]  5000 10000</code></pre>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">mat[<span class="dv">1</span>:<span class="dv">5</span>, <span class="dv">1</span>:<span class="dv">5</span>]</code></pre></div>
<pre><code>##      [,1] [,2] [,3] [,4] [,5]
## [1,]    0    0    0    0    0
## [2,]    0    0    0    0    0
## [3,]    0    0    0    0    0
## [4,]    0    0    0    0    0
## [5,]    0    0    0    0    0</code></pre>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">mat[<span class="dv">1</span>, <span class="dv">1</span>] &lt;-<span class="st"> </span><span class="dv">2</span>
mat[<span class="dv">1</span>:<span class="dv">5</span>, <span class="dv">1</span>:<span class="dv">5</span>]</code></pre></div>
<pre><code>##      [,1] [,2] [,3] [,4] [,5]
## [1,]    2    0    0    0    0
## [2,]    0    0    0    0    0
## [3,]    0    0    0    0    0
## [4,]    0    0    0    0    0
## [5,]    0    0    0    0    0</code></pre>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">mat[<span class="dv">2</span>:<span class="dv">4</span>] &lt;-<span class="st"> </span><span class="dv">3</span>
mat[<span class="dv">1</span>:<span class="dv">5</span>, <span class="dv">1</span>:<span class="dv">5</span>]</code></pre></div>
<pre><code>##      [,1] [,2] [,3] [,4] [,5]
## [1,]    2    0    0    0    0
## [2,]    3    0    0    0    0
## [3,]    3    0    0    0    0
## [4,]    3    0    0    0    0
## [5,]    0    0    0    0    0</code></pre>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">mat[, <span class="dv">2</span>:<span class="dv">3</span>] &lt;-<span class="st"> </span><span class="kw">rnorm</span>(<span class="dv">2</span> *<span class="st"> </span><span class="kw">nrow</span>(mat))
mat[<span class="dv">1</span>:<span class="dv">5</span>, <span class="dv">1</span>:<span class="dv">5</span>]</code></pre></div>
<pre><code>##      [,1]        [,2]       [,3] [,4] [,5]
## [1,]    2 -1.88557153 -2.2445336    0    0
## [2,]    3 -2.01425603 -0.2505295    0    0
## [3,]    3 -0.02695861  0.2668749    0    0
## [4,]    3 -1.44288760  1.0518575    0    0
## [5,]    0  0.28056538  0.1922316    0    0</code></pre>
<p>What we can see is that big matrices (<code>big.matrix</code> objects) can be accessed (read/write) almost as if they were standard R matrices, but you have to be cautious. For example, doing <code>mat[1, ]</code> isn’t recommended. Indeed, big matrices, as standard R matrices, are stored by column so that it is in fact a big vector with columns stored one after the other, contiguously. So, accessing the first row would access elements that are not stored contiguously in memory, which is slow. One should always access columns rather than rows.</p>
</div>
<div id="apply-an-r-function-to-a-big-matrix" class="section level2">
<h2>Apply an R function to a big matrix</h2>
<p>An easy strategy to apply an R function to a big matrix would be the split-apply-combine strategy <span class="citation">(Wickham 2011)</span>. For example, you could access only a block of columns at a time, apply a (vectorized) function to this block, and then combine the results of all blocks. This is implemented in function <code>big_apply()</code>.</p>
<p><img src="https://raw.githubusercontent.com/privefl/useR-2017/master/split-apply-combine.svg" style="display: block; margin: auto;" /></p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="co"># Compute the sums of the first 1000 columns</span>
colsums_1 &lt;-<span class="st"> </span><span class="kw">colSums</span>(mat[, <span class="dv">1</span>:<span class="dv">1000</span>])
<span class="co"># Compute the sums of the second block of 1000 columns</span>
colsums_2 &lt;-<span class="st"> </span><span class="kw">colSums</span>(mat[, <span class="dv">1001</span>:<span class="dv">2000</span>])
<span class="co"># Combine the results</span>
colsums_1_2 &lt;-<span class="st"> </span><span class="kw">c</span>(colsums_1, colsums_2)
<span class="co"># Do this automatically with big_apply()</span>
colsums_all &lt;-<span class="st"> </span><span class="kw">big_apply</span>(mat, <span class="dt">a.FUN =</span> function(X, ind) <span class="kw">colSums</span>(X[, ind]), 
                         <span class="dt">a.combine =</span> <span class="st">&#39;c&#39;</span>)</code></pre></div>
<p>When the split-apply-combine strategy can be used for a given function, you could use <code>big_apply()</code> to get the results, while accessing only small blocks of columns (or rows) at a time. Package <strong>biganalytics</strong>, by the creators of <strong>bigmemory</strong>, provides a way to apply an R function to margins of a <code>big.matrix</code>. Yet, for example, if the <code>big.matrix</code> has a lot of columns, it would be much slower to loop through all columns rather that applying a vectorized function to blocks of columns. You can find more example <a href="https://privefl.github.io/bigstatsr/reference/big_apply.html">there</a>.</p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">colsums_all2 &lt;-<span class="st"> </span>biganalytics::<span class="kw">apply</span>(mat, <span class="dv">2</span>, sum)
<span class="kw">all.equal</span>(colsums_all2, colsums_all)</code></pre></div>
<pre><code>## [1] TRUE</code></pre>
</div>
<div id="use-rcpp-with-a-big-matrix" class="section level2">
<h2>Use Rcpp with a big matrix</h2>
<p>Using Rcpp with a <code>big.matrix</code> is super easy. Let’s use the previous example, i.e. the computation of the colsums of a <code>big.matrix</code>. We will do it in 3 different ways.</p>
<div id="using-the-bigmemory-way" class="section level3">
<h3>1. Using the bigmemory way</h3>
<div class="sourceCode"><pre class="sourceCode cpp"><code class="sourceCode cpp"><span class="co">// [[Rcpp::depends(bigmemory, BH)]]</span>
<span class="ot">#include &lt;bigmemory/MatrixAccessor.hpp&gt;</span>
<span class="ot">#include &lt;Rcpp.h&gt;</span>

<span class="kw">using</span> <span class="kw">namespace</span> Rcpp;

<span class="co">// [[Rcpp::export]]</span>
NumericVector bigcolsums(<span class="dt">const</span> S4&amp; BM) {
  
  XPtr&lt;BigMatrix&gt; xpMat = BM.slot(<span class="st">&quot;address&quot;</span>);
  MatrixAccessor&lt;<span class="dt">double</span>&gt; macc(*xpMat);
  
  <span class="dt">int</span> n = macc.nrow();
  <span class="dt">int</span> m = macc.ncol();

  NumericVector res(m); <span class="co">// vector of m zeros</span>
  <span class="dt">int</span> i, j;

  <span class="kw">for</span> (j = <span class="dv">0</span>; j &lt; m; j++) 
    <span class="kw">for</span> (i = <span class="dv">0</span>; i &lt; n; i++) 
      res[j] += macc[j][i];

  <span class="kw">return</span> res;
}</code></pre></div>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">colsums_all3 &lt;-<span class="st"> </span><span class="kw">bigcolsums</span>(mat)
<span class="kw">all.equal</span>(colsums_all3, colsums_all)</code></pre></div>
<pre><code>## [1] TRUE</code></pre>
</div>
<div id="using-the-bigstatsr-way" class="section level3">
<h3>2. Using the bigstatsr way</h3>
<div class="sourceCode"><pre class="sourceCode cpp"><code class="sourceCode cpp"><span class="co">// [[Rcpp::depends(bigstatsr, bigmemory, BH)]]</span>
<span class="ot">#include &lt;bigstatsr/SubMatAcc.h&gt;</span>

<span class="co">// [[Rcpp::export]]</span>
NumericVector bigcolsums2(<span class="dt">const</span> S4&amp; BM,
                          <span class="dt">const</span> IntegerVector&amp; rowInd,
                          <span class="dt">const</span> IntegerVector&amp; colInd) {
  
  XPtr&lt;BigMatrix&gt; xpMat = BM.slot(<span class="st">&quot;address&quot;</span>);
  <span class="co">// C++ indices begin at 0</span>
  IntegerVector rows = rowInd - <span class="dv">1</span>;
  IntegerVector cols = colInd - <span class="dv">1</span>;
  <span class="co">// An accessor of only part of the big.matrix</span>
  SubMatAcc&lt;<span class="dt">double</span>&gt; macc(*xpMat, rows, cols);
  
  <span class="dt">int</span> n = macc.nrow();
  <span class="dt">int</span> m = macc.ncol();

  NumericVector res(m); <span class="co">// vector of m zeros</span>
  <span class="dt">int</span> i, j;

  <span class="kw">for</span> (j = <span class="dv">0</span>; j &lt; m; j++) 
    <span class="kw">for</span> (i = <span class="dv">0</span>; i &lt; n; i++) 
      res[j] += macc(i, j);

  <span class="kw">return</span> res;
}</code></pre></div>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">colsums_all4 &lt;-<span class="st"> </span><span class="kw">bigcolsums2</span>(mat, <span class="kw">rows_along</span>(mat), <span class="kw">cols_along</span>(mat))
<span class="kw">all.equal</span>(colsums_all4, colsums_all)</code></pre></div>
<pre><code>## [1] TRUE</code></pre>
<p>In <strong>bigstatsr</strong>, most of the functions have parameters for subsetting rows and columns because it is often useful. One of the main reasons why I don’t use package <strong>bigalgebra</strong> is its lack of subsetting options.</p>
</div>
<div id="use-an-already-implemented-function" class="section level3">
<h3>3. Use an already implemented function</h3>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">str</span>(colsums_all5 &lt;-<span class="st"> </span><span class="kw">big_colstats</span>(mat))</code></pre></div>
<pre><code>## &#39;data.frame&#39;:    10000 obs. of  2 variables:
##  $ sum: num  11 2.99 -5.61 0 0 ...
##  $ var: num  0.0062 1.0123 1.0437 0 0 ...</code></pre>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">all.equal</span>(colsums_all5$sum, colsums_all)</code></pre></div>
<pre><code>## [1] TRUE</code></pre>
</div>
</div>
<div id="principal-component-analysis" class="section level2">
<h2>Principal Component Analysis</h2>
<p>Let’s begin by filling the matrix with random numbers in a tricky way.</p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">U &lt;-<span class="st"> </span><span class="kw">sweep</span>(<span class="kw">matrix</span>(<span class="kw">rnorm</span>(<span class="kw">nrow</span>(mat) *<span class="st"> </span><span class="dv">10</span>), <span class="dt">ncol =</span> <span class="dv">10</span>), <span class="dv">2</span>, <span class="dv">1</span>:<span class="dv">10</span>, <span class="st">&quot;/&quot;</span>)
V &lt;-<span class="st"> </span><span class="kw">matrix</span>(<span class="kw">rnorm</span>(<span class="kw">ncol</span>(mat) *<span class="st"> </span><span class="dv">10</span>), <span class="dt">ncol =</span> <span class="dv">10</span>)
<span class="kw">big_apply</span>(mat, <span class="dt">a.FUN =</span> function(X, ind) {
  X[, ind] &lt;-<span class="st"> </span><span class="kw">tcrossprod</span>(U, V[ind, ]) +<span class="st"> </span><span class="kw">rnorm</span>(<span class="kw">nrow</span>(X) *<span class="st"> </span><span class="kw">length</span>(ind))
  <span class="ot">NULL</span>
}, <span class="dt">a.combine =</span> <span class="st">&#39;c&#39;</span>)</code></pre></div>
<pre><code>## NULL</code></pre>
<p>Let’s say we want the first 10 PCs of the (scaled) matrix.</p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">system.time</span>(
  small_svd &lt;-<span class="st"> </span><span class="kw">svd</span>(<span class="kw">scale</span>(mat[, <span class="dv">1</span>:<span class="dv">2000</span>]), <span class="dt">nu =</span> <span class="dv">10</span>, <span class="dt">nv =</span> <span class="dv">10</span>)
)</code></pre></div>
<pre><code>##    user  system elapsed 
##   9.850   0.057   9.908</code></pre>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">system.time</span>(
  small_svd2 &lt;-<span class="st"> </span><span class="kw">big_SVD</span>(mat, <span class="kw">big_scale</span>(), <span class="dt">ind.col =</span> <span class="dv">1</span>:<span class="dv">2000</span>)
)</code></pre></div>
<pre><code>## (2)</code></pre>
<pre><code>##    user  system elapsed 
##   2.191   0.225   2.417</code></pre>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">plot</span>(small_svd2$u, small_svd$u)</code></pre></div>
<p><img src="{{ site.url }}{{ site.baseurl }}/knitr_files/post-bigstatsr_files/figure-html/unnamed-chunk-13-1.png" style="display: block; margin: auto;" /></p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">system.time</span>(
  small_svd3 &lt;-<span class="st"> </span><span class="kw">big_randomSVD</span>(mat, <span class="kw">big_scale</span>(), <span class="dt">ind.col =</span> <span class="dv">1</span>:<span class="dv">2000</span>)
)</code></pre></div>
<pre><code>##    user  system elapsed 
##   0.355   0.000   0.355</code></pre>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">plot</span>(small_svd3$u, small_svd$u)</code></pre></div>
<p><img src="{{ site.url }}{{ site.baseurl }}/knitr_files/post-bigstatsr_files/figure-html/unnamed-chunk-13-2.png" style="display: block; margin: auto;" /></p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">system.time</span>(
  svd_all &lt;-<span class="st"> </span><span class="kw">big_randomSVD</span>(mat, <span class="kw">big_scale</span>())
)</code></pre></div>
<pre><code>##    user  system elapsed 
##   1.746   0.028   1.773</code></pre>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">plot</span>(svd_all)</code></pre></div>
<p><img src="{{ site.url }}{{ site.baseurl }}/knitr_files/post-bigstatsr_files/figure-html/unnamed-chunk-14-1.png" style="display: block; margin: auto;" /></p>
<p>Function <code>big_randomSVD()</code> uses Rcpp and package <strong>Rpsectra</strong> to implement a fast Singular Value Decomposition for a <code>big.matrix</code> that is linear in all dimensions (standard PCA algorithm is quadratic in the smallest dimension) which makes is very fast even for large datasets (that have both dimensions that are large).</p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">str</span>(mat)</code></pre></div>
<pre><code>## Formal class &#39;big.matrix&#39; [package &quot;bigmemory&quot;] with 1 slot
##   ..@ address:&lt;externalptr&gt;</code></pre>
</div>
<div id="some-linear-models" class="section level2">
<h2>Some linear models</h2>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">print</span>(<span class="kw">ncol</span>(mat))</code></pre></div>
<pre><code>## [1] 10000</code></pre>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">M &lt;-<span class="st"> </span><span class="dv">100</span> <span class="co"># number of causal variables</span>
set &lt;-<span class="st"> </span><span class="kw">sample</span>(<span class="kw">ncol</span>(mat), M)
y &lt;-<span class="st"> </span>mat[, set] %*%<span class="st"> </span><span class="kw">rnorm</span>(M)
y &lt;-<span class="st"> </span>y +<span class="st"> </span><span class="kw">rnorm</span>(<span class="kw">length</span>(y), <span class="dt">sd =</span> <span class="dv">2</span> *<span class="st"> </span><span class="kw">sd</span>(y))

ind.train &lt;-<span class="st"> </span><span class="kw">sort</span>(<span class="kw">sample</span>(<span class="kw">nrow</span>(mat), <span class="dt">size =</span> <span class="fl">0.8</span> *<span class="st"> </span><span class="kw">nrow</span>(mat)))
ind.test &lt;-<span class="st"> </span><span class="kw">setdiff</span>(<span class="kw">rows_along</span>(mat), ind.train)

mult_test &lt;-<span class="st"> </span><span class="kw">big_univLinReg</span>(mat, y[ind.train], <span class="dt">ind.train =</span> ind.train, 
                            <span class="dt">covar.train =</span> svd_all$u[ind.train, ])</code></pre></div>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">library</span>(ggplot2)
<span class="kw">plot</span>(mult_test) +<span class="st"> </span>
<span class="st">  </span><span class="kw">aes</span>(<span class="dt">color =</span> <span class="kw">cols_along</span>(mat) %in%<span class="st"> </span>set) +
<span class="st">  </span><span class="kw">labs</span>(<span class="dt">color =</span> <span class="st">&quot;Causal?&quot;</span>)</code></pre></div>
<p><img src="{{ site.url }}{{ site.baseurl }}/knitr_files/post-bigstatsr_files/figure-html/unnamed-chunk-17-1.png" style="display: block; margin: auto;" /></p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">train &lt;-<span class="st"> </span><span class="kw">big_spLinReg</span>(mat, y[ind.train], <span class="dt">ind.train =</span> ind.train, 
                      <span class="dt">covar.train =</span> svd_all$u[ind.train, ],
                      <span class="dt">alpha =</span> <span class="fl">0.5</span>)
pred &lt;-<span class="st"> </span><span class="kw">predict</span>(train, <span class="dt">X. =</span> mat, <span class="dt">ind.row =</span> ind.test, <span class="dt">covar.row =</span> svd_all$u[ind.test, ])
<span class="kw">plot</span>(<span class="kw">apply</span>(pred, <span class="dv">2</span>, cor, <span class="dt">y =</span> y[ind.test]))</code></pre></div>
<pre><code>## Warning in FUN(newX[, i], ...): l&#39;écart type est nulle</code></pre>
<p><img src="{{ site.url }}{{ site.baseurl }}/knitr_files/post-bigstatsr_files/figure-html/unnamed-chunk-18-1.png" style="display: block; margin: auto;" /></p>
<p>The functions <code>big_spLinReg()</code>, <code>big_spLogReg()</code> and <code>big_spSVM()</code> all use lasso (L1) or elastic-net (L1 &amp; L2) regularizations in order to limit the number of predictors and to accelerate computations thanks to strong rules <span class="citation">(R. Tibshirani et al. 2012)</span>. The implementation of these functions are based on modifications from packages <strong>sparseSVM</strong> and <strong>biglasso</strong> <span class="citation">(Zeng and Breheny 2017)</span>. Yet, these models give predictions for a range of 100 different regularization parameters whereas we are only interested in one prediction.</p>
<p>So, that’s why I came up with the idea of Cross-Model Selection and Averaging (CMSA), which principle is:</p>
<ol style="list-style-type: decimal">
<li>This function separates the training set in K folds (e.g. 10).</li>
<li><strong>In turn</strong>,
<ul>
<li>each fold is considered as an inner validation set and the others (K - 1) folds form an inner training set,</li>
<li>the model is trained on the inner training set and the corresponding predictions (scores) for the inner validation set are computed,</li>
<li>the vector of coefficients corresponding to the vector of scores which maximizes <code>feval</code> is chosen.</li>
</ul></li>
<li>The K resulting vectors of coefficients are then combined into one vector.</li>
</ol>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">train2 &lt;-<span class="st"> </span><span class="kw">big_CMSA</span>(big_spLinReg, <span class="dt">feval =</span> function(pred, target) <span class="kw">cor</span>(pred, target), 
                   <span class="dt">X. =</span> mat, <span class="dt">y.train =</span> y[ind.train], <span class="dt">ind.train =</span> ind.train, 
                      <span class="dt">covar.train =</span> svd_all$u[ind.train, ],
                      <span class="dt">alpha =</span> <span class="fl">0.5</span>, <span class="dt">ncores =</span> parallel::<span class="kw">detectCores</span>() /<span class="st"> </span><span class="dv">2</span>)</code></pre></div>
<pre><code>## Warning in cor(pred, target): l&#39;écart type est nulle

## Warning in cor(pred, target): l&#39;écart type est nulle

## Warning in cor(pred, target): l&#39;écart type est nulle

## Warning in cor(pred, target): l&#39;écart type est nulle

## Warning in cor(pred, target): l&#39;écart type est nulle

## Warning in cor(pred, target): l&#39;écart type est nulle

## Warning in cor(pred, target): l&#39;écart type est nulle

## Warning in cor(pred, target): l&#39;écart type est nulle

## Warning in cor(pred, target): l&#39;écart type est nulle

## Warning in cor(pred, target): l&#39;écart type est nulle</code></pre>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">mean</span>(train2 !=<span class="st"> </span><span class="dv">0</span>) <span class="co"># percentage of predictors </span></code></pre></div>
<pre><code>## [1] 0.1423576</code></pre>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">pred2 &lt;-<span class="st"> </span><span class="kw">predict</span>(train2, <span class="dt">X. =</span> mat, <span class="dt">ind.row =</span> ind.test, <span class="dt">covar.row =</span> svd_all$u[ind.test, ])
<span class="kw">cor</span>(pred2, y[ind.test])</code></pre></div>
<pre><code>## [1] 0.2929135</code></pre>
</div>
<div id="some-matrix-computations" class="section level2">
<h2>Some matrix computations</h2>
<p>We can take the example of the computation of the correlation of the first 2000 columns.</p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">system.time</span>(
  corr &lt;-<span class="st"> </span><span class="kw">cor</span>(mat[, <span class="dv">1</span>:<span class="dv">2000</span>])
)</code></pre></div>
<pre><code>##    user  system elapsed 
##  12.748   0.008  12.753</code></pre>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">system.time</span>(
  corr2 &lt;-<span class="st"> </span><span class="kw">big_cor</span>(mat, <span class="dt">ind.col =</span> <span class="dv">1</span>:<span class="dv">2000</span>)
)</code></pre></div>
<pre><code>##    user  system elapsed 
##   0.820   0.009   0.832</code></pre>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">all.equal</span>(corr2, corr)</code></pre></div>
<pre><code>## [1] TRUE</code></pre>
</div>
<div id="advantages-of-using-big.matrix-objects" class="section level2">
<h2>Advantages of using big.matrix objects</h2>
<ul>
<li>you can apply algorithms on 100GB of data,</li>
<li>you can easily parallelize your algorithms because the data on disk is shared,</li>
<li>you write more efficient algorithms,</li>
<li>you can use different types of data, for example, in my field, I’m storing my data with only 1 byte per element (rather than 8 bytes for a standard R matrix).</li>
</ul>
</div>
<div id="references" class="section level2 unnumbered">
<h2>References</h2>
<div id="refs" class="references">
<div id="ref-Kane2013">
<p>Kane, Michael J, John W Emerson, and Stephen Weston. 2013. “Scalable Strategies for Computing with Massive Data.” <em>Journal of Statistical Software</em> 55 (14): 1–19. doi:<a href="https://doi.org/10.18637/jss.v055.i14">10.18637/jss.v055.i14</a>.</p>
</div>
<div id="ref-Tibshirani2012">
<p>Tibshirani, Robert, Jacob Bien, Jerome Friedman, Trevor Hastie, Noah Simon, Jonathan Taylor, and Ryan J Tibshirani. 2012. “Strong rules for discarding predictors in lasso-type problems.” <em>Journal of the Royal Statistical Society. Series B, Statistical Methodology</em> 74 (2): 245–66. doi:<a href="https://doi.org/10.1111/j.1467-9868.2011.01004.x">10.1111/j.1467-9868.2011.01004.x</a>.</p>
</div>
<div id="ref-Wickham2011">
<p>Wickham, Hadley. 2011. “The Split-Apply-Combine Strategy for Data Analysis. Journal of Statistical Software.” <em>Journal of Statistical Software</em> 40 (1): 1–29. doi:<a href="https://doi.org/10.1039/np9971400083">10.1039/np9971400083</a>.</p>
</div>
<div id="ref-Zeng2017">
<p>Zeng, Yaohui, and Patrick Breheny. 2017. “The biglasso Package: A Memory- and Computation-Efficient Solver for Lasso Model Fitting with Big Data in R,” January. <a href="http://arxiv.org/abs/1701.05936" class="uri">http://arxiv.org/abs/1701.05936</a>.</p>
</div>
</div>
</div>
</section>
