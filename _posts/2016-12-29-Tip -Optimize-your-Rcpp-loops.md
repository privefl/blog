---
title: "Tip: Optimize your Rcpp loops"
author: "Florian Privé"
date: "December 29, 2016" # DO NOT USE Sys.Date()
layout: post
---



<section class="main-content">
<p>In this post, I will show you how to optimize your <code>Rcpp</code> loops so that they are 2 to 3 times faster than a standard implementation.</p>
<div id="context" class="section level2">
<h2>Context</h2>
<div id="real-data-example" class="section level3">
<h3>Real data example</h3>
<p>For this post, I will use a <code>big.matrix</code> which represents genotypes for 15,283 individuals, corresponding to the number of mutations (0, 1 or 2) at 287,155 different loci. Here, I will use only the first 10,000 loci (columns).</p>
<p>What you need to know about the <code>big.matrix</code> format:</p>
<ul>
<li>you can easily and quickly access matrice-like objects stored on disk,</li>
<li>you can use different types of storage (I use type <code>char</code> to store each element on only 1 byte),</li>
<li>it is column-major ordered as standard <code>R</code> matrices,</li>
<li>you can access elements of a <code>big.matrix</code> using <code>X[i, j]</code> in <code>R</code>,</li>
<li>you can access elements of a <code>big.matrix</code> using <code>X[j][i]</code> in <code>Rcpp</code>,</li>
<li>you can get a <code>RcppEigen</code> or <code>RcppArmadillo</code> view of a <code>big.matrix</code> (see Appendix).</li>
<li>for more details, go to <a href="https://github.com/kaneplusplus/bigmemory">the GitHub repo</a>.</li>
</ul>
<p>Peek at the data:</p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">print</span>(<span class="kw">dim</span>(X))</code></pre></div>
<pre><code>## [1] 15283 10000</code></pre>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">print</span>(X[<span class="dv">1</span>:<span class="dv">10</span>, <span class="dv">1</span>:<span class="dv">12</span>])</code></pre></div>
<pre><code>##       [,1] [,2] [,3] [,4] [,5] [,6] [,7] [,8] [,9] [,10] [,11] [,12]
##  [1,]    2    0    2    0    2    2    2    1    2     2     2     2
##  [2,]    2    0    1    2    1    1    1    1    2     1     2     2
##  [3,]    2    0    2    2    2    2    1    1    2     1     2     2
##  [4,]    2    2    0    2    0    0    0    2    2     2     0     2
##  [5,]    2    1    2    2    2    2    2    1    2     2     2     2
##  [6,]    2    1    2    1    2    2    1    1    2     2     2     2
##  [7,]    2    0    2    0    2    2    2    0    2     1     2     2
##  [8,]    2    1    1    2    1    1    1    1    2     1     2     2
##  [9,]    2    1    2    2    2    2    2    2    2     2     2     2
## [10,]    2    0    2    1    2    2    2    0    2     1     2     1</code></pre>
</div>
<div id="what-i-needed" class="section level3">
<h3>What I needed</h3>
<p>I needed a fast matrix-vector multiplication between a <code>big.matrix</code> and a vector. Moreover, I could not use any <code>RcppEigen</code> or <code>RcppArmadillo</code> multiplication because I needed some options of efficiently subsetting columns or rows in my matrix (see Appendix).</p>
<p>Writing this multiplication in <code>Rcpp</code> is no more than two loops:</p>
<div class="sourceCode"><pre class="sourceCode cpp"><code class="sourceCode cpp"><span class="co">// [[Rcpp::depends(RcppEigen, bigmemory, BH)]]</span>
<span class="ot">#include &lt;RcppEigen.h&gt;</span>
<span class="ot">#include &lt;bigmemory/MatrixAccessor.hpp&gt;</span>

<span class="kw">using</span> <span class="kw">namespace</span> Rcpp;

<span class="co">// [[Rcpp::export]]</span>
NumericVector prod1(XPtr&lt;BigMatrix&gt; bMPtr, <span class="dt">const</span> NumericVector&amp; x) {
  
  MatrixAccessor&lt;<span class="dt">char</span>&gt; macc(*bMPtr);

  <span class="dt">int</span> n = bMPtr-&gt;nrow();
  <span class="dt">int</span> m = bMPtr-&gt;ncol();

  NumericVector res(n);
  <span class="dt">int</span> i, j;
  
  <span class="kw">for</span> (j = <span class="dv">0</span>; j &lt; m; j++) {
    <span class="kw">for</span> (i = <span class="dv">0</span>; i &lt; n; i++) {
      res[i] += macc[j][i] * x[j];
    }
  }

  <span class="kw">return</span> res;
}</code></pre></div>
<p>One test:</p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">y &lt;-<span class="st"> </span><span class="kw">rnorm</span>(<span class="kw">ncol</span>(X))

<span class="kw">print</span>(<span class="kw">system.time</span>(
  test &lt;-<span class="st"> </span><span class="kw">prod1</span>(X@address, y)
))</code></pre></div>
<pre><code>##    user  system elapsed 
##   0.664   0.004   0.668</code></pre>
<p><strong>What comes next should be transposable to other applications and other types of data.</strong></p>
</div>
</div>
<div id="unrolling-optimization" class="section level2">
<h2>Unrolling optimization</h2>
<p>While searching for optimizing my multiplication, I came across <a href="http://stackoverflow.com/a/12289513/6103040">this Stack Overflow answer</a>.</p>
<p>Unrolling in action:</p>
<div class="sourceCode"><pre class="sourceCode cpp"><code class="sourceCode cpp"><span class="co">// [[Rcpp::depends(RcppEigen, bigmemory, BH)]]</span>
<span class="ot">#include &lt;RcppEigen.h&gt;</span>
<span class="ot">#include &lt;bigmemory/MatrixAccessor.hpp&gt;</span>

<span class="kw">using</span> <span class="kw">namespace</span> Rcpp;

<span class="co">// [[Rcpp::export]]</span>
NumericVector prod4(XPtr&lt;BigMatrix&gt; bMPtr, <span class="dt">const</span> NumericVector&amp; x) {
  
  MatrixAccessor&lt;<span class="dt">char</span>&gt; macc(*bMPtr);
  
  <span class="dt">int</span> n = bMPtr-&gt;nrow();
  <span class="dt">int</span> m = bMPtr-&gt;ncol();
  
  NumericVector res(n);
  <span class="dt">int</span> i, j;
  
  <span class="kw">for</span> (j = <span class="dv">0</span>; j &lt;= m - <span class="dv">4</span>; j += <span class="dv">4</span>) {
    <span class="kw">for</span> (i = <span class="dv">0</span>; i &lt; n; i++) { <span class="co">// unrolling optimization</span>
      res[i] += (x[j] * macc[j][i] + x[j<span class="dv">+1</span>] * macc[j<span class="dv">+1</span>][i]) +
        (x[j<span class="dv">+2</span>] * macc[j<span class="dv">+2</span>][i] + x[j<span class="dv">+3</span>] * macc[j<span class="dv">+3</span>][i]);
    } <span class="co">// The parentheses are somehow important. Try without.</span>
  }
  <span class="kw">for</span> (; j &lt; m; j++) {
    <span class="kw">for</span> (i = <span class="dv">0</span>; i &lt; n; i++) {
      res[i] += x[j] * macc[j][i];
    }
  }
  
  <span class="kw">return</span> res;
}</code></pre></div>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">require</span>(microbenchmark)

<span class="kw">print</span>(<span class="kw">microbenchmark</span>(
  <span class="dt">PROD1 =</span> test1 &lt;-<span class="st"> </span><span class="kw">prod1</span>(X@address, y),
  <span class="dt">PROD4 =</span> test2 &lt;-<span class="st"> </span><span class="kw">prod4</span>(X@address, y),
  <span class="dt">times =</span> <span class="dv">5</span>
))</code></pre></div>
<pre><code>## Unit: milliseconds
##   expr      min       lq     mean   median       uq      max neval
##  PROD1 609.0916 612.6428 613.7418 613.3740 616.4907 617.1096     5
##  PROD4 262.2658 267.7352 267.0268 268.0026 268.0785 269.0521     5</code></pre>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">print</span>(<span class="kw">all.equal</span>(test1, test2))</code></pre></div>
<pre><code>## [1] TRUE</code></pre>
<p>Nice! Let’s try more. Why not using 8 or 16 rather than 4?</p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">Rcpp::<span class="kw">sourceCpp</span>(<span class="st">&#39;{{ site.url }}{{ site.baseurl }}/code/prods.cpp&#39;</span>)

<span class="kw">print</span>(bench &lt;-<span class="st"> </span><span class="kw">microbenchmark</span>(
  <span class="dt">PROD1 =</span> <span class="kw">prod1</span>(X@address, y),
  <span class="dt">PROD2 =</span> <span class="kw">prod2</span>(X@address, y),
  <span class="dt">PROD4 =</span> <span class="kw">prod4</span>(X@address, y),
  <span class="dt">PROD8 =</span> <span class="kw">prod8</span>(X@address, y),
  <span class="dt">PROD16 =</span> <span class="kw">prod16</span>(X@address, y),
  <span class="dt">times =</span> <span class="dv">5</span>
))</code></pre></div>
<pre><code>## Unit: milliseconds
##    expr      min       lq     mean   median       uq      max neval
##   PROD1 620.9375 627.9209 640.6087 631.1818 659.4236 663.5798     5
##   PROD2 407.6275 418.1752 417.1746 418.4589 419.0665 422.5451     5
##   PROD4 267.1687 271.4726 283.1928 271.9553 279.6698 325.6979     5
##   PROD8 241.5542 242.9120 255.4974 246.5218 267.7683 278.7307     5
##  PROD16 212.4335 213.5228 217.4781 217.1801 221.5119 222.7423     5</code></pre>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">time &lt;-<span class="st"> </span><span class="kw">summary</span>(bench)[, <span class="st">&quot;median&quot;</span>]
step &lt;-<span class="st"> </span><span class="dv">2</span>^(<span class="dv">0</span>:<span class="dv">4</span>)
<span class="kw">plot</span>(step, time, <span class="dt">type =</span> <span class="st">&quot;b&quot;</span>, <span class="dt">xaxt =</span> <span class="st">&quot;n&quot;</span>, <span class="dt">yaxt =</span> <span class="st">&quot;n&quot;</span>, 
     <span class="dt">xlab =</span> <span class="st">&quot;size of each step&quot;</span>)
<span class="kw">axis</span>(<span class="dt">side =</span> <span class="dv">1</span>, <span class="dt">at =</span> step)
<span class="kw">axis</span>(<span class="dt">side =</span> <span class="dv">2</span>, <span class="dt">at =</span> <span class="kw">round</span>(time))</code></pre></div>
<p><img src="{{ site.url }}{{ site.baseurl }}/knitr_files/post-optimize-rcpp-loops_files/figure-html/unnamed-chunk-7-1.png" style="display: block; margin: auto;" /></p>
</div>
<div id="conclusion" class="section level2">
<h2>Conclusion</h2>
<p>We have seen that unrolling can dramatically improve performances on loops. Steps of size 8 or 16 are of relatively little extra gain compared to 2 or 4.</p>
<p>As pointed out in the SO answer, it can behave rather differently between systems. So, if it is for your personal use, use the maximum gain (try 32!), but as I want my function to be used by others in a package, I think it’s safer to choose a step of 4.</p>
</div>
<div id="appendix" class="section level2">
<h2>Appendix</h2>
<p>You can do a <code>big.matrix</code>-vector multiplication easily with <code>RcppEigen</code> or <code>RcppArmadillo</code> (see <a href="{{ site.url }}{{ site.baseurl }}/code/prods2.cpp">this code</a>) but it lacks of efficient subsetting option.</p>
<p>Indeed, you still can’t use subsetting in <code>Eigen</code>, but this will come as said in <a href="http://eigen.tuxfamily.org/bz/show_bug.cgi?id=329">this feature request</a>. For <code>Armadillo</code>, you can but it is rather slow:</p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">Rcpp::<span class="kw">sourceCpp</span>(<span class="st">&#39;{{ site.url }}{{ site.baseurl }}/code/prods2.cpp&#39;</span>)

n &lt;-<span class="st"> </span><span class="kw">nrow</span>(X)
ind &lt;-<span class="st"> </span><span class="kw">sort</span>(<span class="kw">sample</span>(n, <span class="dt">size =</span> n/<span class="dv">2</span>))

<span class="kw">print</span>(<span class="kw">microbenchmark</span>(
  <span class="dt">EIGEN =</span> test3 &lt;-<span class="st"> </span><span class="kw">prodEigen</span>(X@address, y),
  <span class="dt">ARMA =</span> test4 &lt;-<span class="st"> </span><span class="kw">prodArma</span>(X@address, y),
  <span class="dt">ARMA_SUB =</span> test5 &lt;-<span class="st"> </span><span class="kw">prodArmaSub</span>(X@address, y, ind -<span class="st"> </span><span class="dv">1</span>),
  <span class="dt">times =</span> <span class="dv">5</span>
))</code></pre></div>
<pre><code>## Unit: milliseconds
##      expr       min        lq      mean    median        uq       max neval
##     EIGEN  567.5607  570.1843  717.2433  572.9402  576.2028 1299.3285     5
##      ARMA 1242.3581 1263.8803 1329.1212 1264.7070 1284.5612 1590.0993     5
##  ARMA_SUB  455.1174  457.5862  466.3982  461.5883  465.9056  491.7935     5</code></pre>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">print</span>(<span class="kw">all</span>(
  <span class="kw">all.equal</span>(test3, test), 
  <span class="kw">all.equal</span>(<span class="kw">as.numeric</span>(test4), test),
  <span class="kw">all.equal</span>(<span class="kw">as.numeric</span>(test5), test[ind])
))</code></pre></div>
<pre><code>## [1] TRUE</code></pre>
</div>
</section>
