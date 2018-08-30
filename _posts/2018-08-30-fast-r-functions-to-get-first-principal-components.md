---
title: "Fast R functions to get first principal components"

author: "Florian Privé"
date: "August 30, 2018"
layout: post
---


<section class="main-content">
<p>In this post, I compare different approaches to get first principal components of large matrices in R.</p>
<div id="comparison" class="section level2">
<h2>Comparison</h2>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">library</span>(bigstatsr)
<span class="kw">library</span>(tidyverse)</code></pre></div>
<div id="data" class="section level3">
<h3>Data</h3>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="co"># Create two matrices, one with some structure, one without</span>
n &lt;-<span class="st"> </span><span class="fl">20e3</span>
seq_m &lt;-<span class="st"> </span><span class="kw">c</span>(<span class="fl">1e3</span>, <span class="fl">3e3</span>, <span class="fl">10e3</span>)
sizes &lt;-<span class="st"> </span><span class="kw">seq_along</span>(seq_m)
X &lt;-<span class="st"> </span>E &lt;-<span class="st"> </span><span class="kw">list</span>()
<span class="cf">for</span> (i <span class="cf">in</span> sizes) {
  m &lt;-<span class="st"> </span>seq_m[i]
  U &lt;-<span class="st"> </span><span class="kw">matrix</span>(<span class="dv">0</span>, n, <span class="dv">10</span>); U[] &lt;-<span class="st"> </span><span class="kw">rnorm</span>(<span class="kw">length</span>(U))
  V &lt;-<span class="st"> </span><span class="kw">matrix</span>(<span class="dv">0</span>, m, <span class="dv">10</span>); V[] &lt;-<span class="st"> </span><span class="kw">rnorm</span>(<span class="kw">length</span>(V))
  E[[i]] &lt;-<span class="st"> </span><span class="kw">matrix</span>(<span class="kw">rnorm</span>(n <span class="op">*</span><span class="st"> </span>m), n, m)
  X[[i]] &lt;-<span class="st"> </span><span class="kw">tcrossprod</span>(U, V) <span class="op">+</span><span class="st"> </span>E[[i]]
}</code></pre></div>
<p>I use matrices of different sizes. Some are structured with 10 hidden components, and some with only random data.</p>
</div>
<div id="optimized-math-library" class="section level3">
<h3>Optimized math library</h3>
<p>I linked my R installation with OpenBLAS, an optimized parallel matrix library.</p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">(NCORES &lt;-<span class="st"> </span>RhpcBLASctl<span class="op">::</span><span class="kw">get_num_cores</span>())</code></pre></div>
<pre><code>## [1] 6</code></pre>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">RhpcBLASctl<span class="op">::</span><span class="kw">blas_set_num_threads</span>(NCORES)</code></pre></div>
<pre><code>## detected function goto_set_num_threads</code></pre>
</div>
<div id="compared-methods" class="section level3">
<h3>Compared methods</h3>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">models &lt;-<span class="st"> </span><span class="kw">tribble</span>(
  <span class="op">~</span>method,                <span class="op">~</span>fun,                      <span class="op">~</span>params,
  <span class="st">&quot;bigstatsr - 1 core&quot;</span>,   bigstatsr<span class="op">::</span>big_randomSVD,  <span class="kw">list</span>(<span class="dt">k =</span> <span class="dv">10</span>),
  <span class="st">&quot;bigstatsr - 6 cores&quot;</span>,  bigstatsr<span class="op">::</span>big_randomSVD,  <span class="kw">list</span>(<span class="dt">k =</span> <span class="dv">10</span>, <span class="dt">ncores =</span> NCORES),
  <span class="st">&quot;Rspectra&quot;</span>,             RSpectra<span class="op">::</span>svds,            <span class="kw">list</span>(<span class="dt">k =</span> <span class="dv">10</span>),
  <span class="st">&quot;irlba&quot;</span>,                irlba<span class="op">::</span>irlba,              <span class="kw">list</span>(<span class="dt">nv =</span> <span class="dv">10</span>, <span class="dt">nu =</span> <span class="dv">10</span>),
  <span class="st">&quot;svd&quot;</span>,                  svd<span class="op">::</span>propack.svd,          <span class="kw">list</span>(<span class="dt">neig =</span> <span class="dv">10</span>),
  <span class="st">&quot;rsvd&quot;</span>,                 rsvd<span class="op">::</span>rsvd,                <span class="kw">list</span>(<span class="dt">k =</span> <span class="dv">10</span>)
) <span class="op">%&gt;%</span>
<span class="st">  </span><span class="kw">mutate</span>(<span class="dt">size =</span> <span class="kw">list</span>(sizes), <span class="dt">structured =</span> <span class="kw">list</span>(<span class="kw">c</span>(<span class="ot">TRUE</span>, <span class="ot">FALSE</span>))) <span class="op">%&gt;%</span>
<span class="st">  </span><span class="kw">unnest</span>(size, <span class="dt">.drop =</span> <span class="ot">FALSE</span>) <span class="op">%&gt;%</span>
<span class="st">  </span><span class="kw">unnest</span>(structured, <span class="dt">.drop =</span> <span class="ot">FALSE</span>) <span class="op">%&gt;%</span>
<span class="st">  </span><span class="kw">mutate</span>(<span class="dt">user_time =</span> <span class="ot">NA</span>, <span class="dt">real_time =</span> <span class="ot">NA</span>, <span class="dt">pcs =</span> <span class="kw">list</span>(<span class="ot">NA</span>))</code></pre></div>
</div>
<div id="computing" class="section level3">
<h3>Computing</h3>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="co"># Filling this data frame with times and PC scores for each method and dataset</span>
<span class="cf">for</span> (i <span class="cf">in</span> <span class="kw">rows_along</span>(models)) {

  mat &lt;-<span class="st"> `</span><span class="dt">if</span><span class="st">`</span>(models<span class="op">$</span>structured[[i]], X, E)[[models<span class="op">$</span>size[[i]]]]

  time &lt;-<span class="st"> </span><span class="kw">system.time</span>({
    <span class="cf">if</span> (<span class="kw">grepl</span>(<span class="st">&quot;bigstatsr&quot;</span>, models<span class="op">$</span>method[[i]])) mat &lt;-<span class="st"> </span><span class="kw">as_FBM</span>(mat)
    res &lt;-<span class="st"> </span><span class="kw">do.call</span>(models<span class="op">$</span>fun[[i]], <span class="dt">args =</span> <span class="kw">c</span>(<span class="kw">list</span>(mat), models<span class="op">$</span>params[[i]]))
  })

  models[[<span class="st">&quot;user_time&quot;</span>]][[i]] &lt;-<span class="st"> </span>time[<span class="dv">1</span>]
  models[[<span class="st">&quot;real_time&quot;</span>]][[i]] &lt;-<span class="st"> </span>time[<span class="dv">3</span>]
  models[[<span class="st">&quot;pcs&quot;</span>]][[i]]  &lt;-<span class="st"> </span>res
}</code></pre></div>
<pre><code>## Warning in (function (X, neig = min(m, n), opts = list()) : Only 4 singular triplets converged
## within 50 iterations.</code></pre>
<pre><code>## Warning in (function (X, neig = min(m, n), opts = list()) : Only 5 singular triplets converged
## within 50 iterations.</code></pre>
<pre><code>## Warning in (function (X, neig = min(m, n), opts = list()) : Only 5 singular triplets converged
## within 50 iterations.</code></pre>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">models &lt;-<span class="st"> </span><span class="kw">mutate</span>(models, <span class="dt">size =</span> seq_m[size])</code></pre></div>
</div>
<div id="timings" class="section level3">
<h3>Timings</h3>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">models <span class="op">%&gt;%</span>
<span class="st">  </span><span class="kw">ggplot</span>(<span class="kw">aes</span>(size <span class="op">/</span><span class="st"> </span><span class="dv">1000</span>, real_time, <span class="dt">color =</span> method)) <span class="op">+</span>
<span class="st">  </span><span class="kw">theme_bigstatsr</span>() <span class="op">+</span>
<span class="st">  </span><span class="kw">geom_point</span>(<span class="dt">cex =</span> <span class="dv">6</span>) <span class="op">+</span>
<span class="st">  </span><span class="kw">geom_line</span>(<span class="kw">aes</span>(<span class="dt">linetype =</span> method), <span class="dt">lwd =</span> <span class="dv">2</span>) <span class="op">+</span>
<span class="st">  </span><span class="kw">facet_grid</span>(structured <span class="op">~</span><span class="st"> </span>., <span class="dt">scales =</span> <span class="st">&quot;free&quot;</span>) <span class="op">+</span>
<span class="st">  </span><span class="kw">theme</span>(<span class="dt">legend.position =</span> <span class="kw">c</span>(<span class="fl">0.25</span>, <span class="fl">0.87</span>),
        <span class="dt">legend.key.width =</span> <span class="kw">unit</span>(<span class="dv">6</span>, <span class="st">&quot;line&quot;</span>)) <span class="op">+</span>
<span class="st">  </span><span class="kw">labs</span>(<span class="dt">x =</span> <span class="kw">sprintf</span>(<span class="st">&quot;ncol (x1000) (nrow = %d)&quot;</span>, n), <span class="dt">y =</span> <span class="st">&quot;Time (in seconds)&quot;</span>,
       <span class="dt">color =</span> <span class="st">&quot;Methods:&quot;</span>, <span class="dt">linetype =</span> <span class="st">&quot;Methods:&quot;</span>)</code></pre></div>
<p><img src="{{ site.url }}{{ site.baseurl }}/knitr_files/post-bench-svd_files/figure-html/unnamed-chunk-6-1.svg" width="70%" style="display: block; margin: auto;" /></p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">models <span class="op">%&gt;%</span>
<span class="st">  </span><span class="kw">filter</span>(size <span class="op">==</span><span class="st"> </span><span class="kw">max</span>(seq_m)) <span class="op">%&gt;%</span>
<span class="st">  </span><span class="kw">select</span>(method, structured, user_time, real_time)</code></pre></div>
<pre><code>## # A tibble: 12 x 4
##    method              structured user_time real_time
##    &lt;chr&gt;               &lt;lgl&gt;          &lt;dbl&gt;     &lt;dbl&gt;
##  1 bigstatsr - 1 core  TRUE           8.10       8.68
##  2 bigstatsr - 1 core  FALSE        106.       107.  
##  3 bigstatsr - 6 cores TRUE           0.456      6.80
##  4 bigstatsr - 6 cores FALSE          0.616     45.3 
##  5 Rspectra            TRUE          17.9        3.39
##  6 Rspectra            FALSE        329.        56.1 
##  7 irlba               TRUE          16.3        3.09
##  8 irlba               FALSE        399.        68.8 
##  9 svd                 TRUE          34.2        6.11
## 10 svd                 FALSE        274.        46.9 
## 11 rsvd                TRUE           4.12       3.89
## 12 rsvd                FALSE          4.06       3.88</code></pre>
</div>
<div id="errors" class="section level3">
<h3>Errors</h3>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">true1 &lt;-<span class="st"> </span><span class="kw">svd</span>(X[[<span class="dv">1</span>]], <span class="dt">nu =</span> <span class="dv">10</span>, <span class="dt">nv =</span> <span class="dv">10</span>)
true2 &lt;-<span class="st"> </span><span class="kw">svd</span>(E[[<span class="dv">1</span>]], <span class="dt">nu =</span> <span class="dv">10</span>, <span class="dt">nv =</span> <span class="dv">10</span>)

bdiff &lt;-<span class="st"> </span><span class="cf">function</span>(x, y) {
  <span class="cf">if</span> (<span class="kw">ncol</span>(x) <span class="op">&lt;</span><span class="st"> </span><span class="kw">ncol</span>(y)) <span class="kw">return</span>(<span class="ot">Inf</span>)
  s =<span class="st"> </span><span class="kw">sign</span>(x[<span class="dv">1</span>, ] <span class="op">/</span><span class="st"> </span>y[<span class="dv">1</span>, ])
  <span class="kw">max</span>(<span class="kw">apply</span>(<span class="kw">sweep</span>(x, <span class="dv">2</span>, s, <span class="st">&#39;*&#39;</span>) <span class="op">-</span><span class="st"> </span>y, <span class="dv">2</span>, crossprod))
}

models <span class="op">%&gt;%</span>
<span class="st">  </span><span class="kw">filter</span>(size <span class="op">==</span><span class="st"> </span><span class="kw">min</span>(seq_m)) <span class="op">%&gt;%</span>
<span class="st">  </span><span class="kw">mutate</span>(<span class="dt">error =</span> <span class="kw">map2_dbl</span>(structured, pcs, <span class="op">~</span>{
    true &lt;-<span class="st"> `</span><span class="dt">if</span><span class="st">`</span>(.x, true1, true2)
    <span class="kw">bdiff</span>(.y<span class="op">$</span>u, true<span class="op">$</span>u)
  })) <span class="op">%&gt;%</span>
<span class="st">  </span><span class="kw">select</span>(method, structured, error)</code></pre></div>
<pre><code>## # A tibble: 12 x 3
##    method              structured      error
##    &lt;chr&gt;               &lt;lgl&gt;           &lt;dbl&gt;
##  1 bigstatsr - 1 core  TRUE         1.63e-27
##  2 bigstatsr - 1 core  FALSE        1.08e- 5
##  3 bigstatsr - 6 cores TRUE         1.29e-27
##  4 bigstatsr - 6 cores FALSE        1.08e- 5
##  5 Rspectra            TRUE         1.63e-27
##  6 Rspectra            FALSE        3.07e-18
##  7 irlba               TRUE         9.06e-26
##  8 irlba               FALSE        1.78e- 7
##  9 svd                 TRUE         6.83e-27
## 10 svd                 FALSE      Inf       
## 11 rsvd                TRUE         7.02e-13
## 12 rsvd                FALSE        2.38e+ 0</code></pre>
</div>
</div>
<div id="conclusion" class="section level2">
<h2>Conclusion</h2>
<ul>
<li><p>Packages {rsvd} and {svd} don’t give results precise enough when data is not structured.</p></li>
<li><p>Packages {bigstatsr} and {irlba} are less precise (but precise enough!) than {RSpectra} because of a different tolerance parameter they use.</p></li>
<li><p>Package {bigstatsr} is as fast as the other packages while not relying on matrix operations (see user timings above). So, even if you don’t have your R installation linked to some optimized math library, you would get the same performance. On the contrary, the other methods would likely be much slower if not using such optimized library.</p></li>
</ul>
<p>So, I highly recommend using package {RSpectra} to compute first principal components, because it is very fast and precise. Moreover, it works with e.g. sparse matrices. Yet, If you have very large matrices or no optimized math library, I would recommend to use my package {bigstatsr} that internally uses {RSpectra} but implements parallel matrix-vector multiplication in Rcpp for its data format <strong>stored on disk</strong>. To learn more on other features of R package {bigstatsr}, please have a look at <a href="https://privefl.github.io/bigstatsr/">the package website</a>.</p>
</div>
</section>
