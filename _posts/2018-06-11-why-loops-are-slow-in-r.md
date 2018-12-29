---
title: "Why loops are slow in R"

author: "Florian Privé"
date: "June 11, 2018"
layout: post
---


<section class="main-content">
<p>In this post, I talk about loops in R, why they can be slow and when it is okay to use them.</p>
<div id="dont-grow-objects" class="section level2">
<h2>Don’t grow objects</h2>
<p>Let us generate a matrix of uniform values (max changing for every column).</p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">gen_grow &lt;-<span class="st"> </span><span class="cf">function</span>(<span class="dt">n =</span> <span class="fl">1e3</span>, <span class="dt">max =</span> <span class="dv">1</span><span class="op">:</span><span class="dv">500</span>) {
  mat &lt;-<span class="st"> </span><span class="ot">NULL</span>
  <span class="cf">for</span> (m <span class="cf">in</span> max) {
    mat &lt;-<span class="st"> </span><span class="kw">cbind</span>(mat, <span class="kw">runif</span>(n, <span class="dt">max =</span> m))
  }
  mat
}</code></pre></div>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">set.seed</span>(<span class="dv">1</span>)
<span class="kw">system.time</span>(mat1 &lt;-<span class="st"> </span><span class="kw">gen_grow</span>(<span class="dt">max =</span> <span class="dv">1</span><span class="op">:</span><span class="dv">500</span>))</code></pre></div>
<pre><code>##    user  system elapsed 
##   0.333   0.189   0.523</code></pre>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">system.time</span>(mat2 &lt;-<span class="st"> </span><span class="kw">gen_grow</span>(<span class="dt">max =</span> <span class="dv">1</span><span class="op">:</span><span class="dv">2000</span>))</code></pre></div>
<pre><code>##    user  system elapsed 
##   6.183   7.603  13.803</code></pre>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">gen_sapply &lt;-<span class="st"> </span><span class="cf">function</span>(<span class="dt">n =</span> <span class="fl">1e3</span>, <span class="dt">max =</span> <span class="dv">1</span><span class="op">:</span><span class="dv">500</span>) {
  <span class="kw">sapply</span>(max, <span class="cf">function</span>(m) <span class="kw">runif</span>(n, <span class="dt">max =</span> m))
}</code></pre></div>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">set.seed</span>(<span class="dv">1</span>)
<span class="kw">system.time</span>(mat3 &lt;-<span class="st"> </span><span class="kw">gen_sapply</span>(<span class="dt">max =</span> <span class="dv">1</span><span class="op">:</span><span class="dv">500</span>))</code></pre></div>
<pre><code>##    user  system elapsed 
##   0.026   0.005   0.030</code></pre>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">identical</span>(mat3, mat1)</code></pre></div>
<pre><code>## [1] TRUE</code></pre>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">system.time</span>(mat4 &lt;-<span class="st"> </span><span class="kw">gen_sapply</span>(<span class="dt">max =</span> <span class="dv">1</span><span class="op">:</span><span class="dv">2000</span>))</code></pre></div>
<pre><code>##    user  system elapsed 
##   0.108   0.014   0.122</code></pre>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">identical</span>(mat4, mat2)</code></pre></div>
<pre><code>## [1] TRUE</code></pre>
<blockquote>
<p>Wow, <code>sapply()</code> is so much faster than loops!</p>
</blockquote>
<p><img src="{{ site.url }}{{ site.baseurl }}/images/bullshit.jpg" width="45%" /></p>
<p>Don’t get this wrong, <code>sapply()</code> or <code>lapply()</code> is nothing but a loop internally, so <strong><code>sapply()</code> shouldn’t be any faster than a loop</strong>. Here, the problem is not with the loop, but what we do inside this loop. Indeed, in <code>gen_grow()</code>, at each iteration of the loop, we reallocate a <em>new</em> matrix with one more column, which takes time.</p>
<p><img src="{{ site.url }}{{ site.baseurl }}/images/stairs.jpg" width="45%" /></p>
<p>Imagine you want to climb all those stairs, but you have to climb only stair 1, go to the bottom then climb the first 2 stairs, go to the bottom then climb the first three, and so on until you reach the top. This takes way more time than just climbing all stairs at once. This is basically what happens in function <code>gen_grow()</code> but instead of climbing more stairs, it allocates more memory, which also takes time.</p>
<p>You have at least two solutions to this problem. The first solution is to pre-allocate the whole result once (if you know its size in advance) and just fill it:</p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">gen_prealloc &lt;-<span class="st"> </span><span class="cf">function</span>(<span class="dt">n =</span> <span class="fl">1e3</span>, <span class="dt">max =</span> <span class="dv">1</span><span class="op">:</span><span class="dv">500</span>) {
  mat &lt;-<span class="st"> </span><span class="kw">matrix</span>(<span class="dv">0</span>, n, <span class="kw">length</span>(max))
  <span class="cf">for</span> (i <span class="cf">in</span> <span class="kw">seq_along</span>(max)) {
    mat[, i] &lt;-<span class="st"> </span><span class="kw">runif</span>(n, <span class="dt">max =</span> max[i])
  }
  mat
}</code></pre></div>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">set.seed</span>(<span class="dv">1</span>)
<span class="kw">system.time</span>(mat5 &lt;-<span class="st"> </span><span class="kw">gen_prealloc</span>(<span class="dt">max =</span> <span class="dv">1</span><span class="op">:</span><span class="dv">500</span>))</code></pre></div>
<pre><code>##    user  system elapsed 
##   0.030   0.000   0.031</code></pre>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">identical</span>(mat5, mat1)</code></pre></div>
<pre><code>## [1] TRUE</code></pre>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">system.time</span>(mat6 &lt;-<span class="st"> </span><span class="kw">gen_prealloc</span>(<span class="dt">max =</span> <span class="dv">1</span><span class="op">:</span><span class="dv">2000</span>))</code></pre></div>
<pre><code>##    user  system elapsed 
##   0.101   0.009   0.109</code></pre>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">identical</span>(mat6, mat2)</code></pre></div>
<pre><code>## [1] TRUE</code></pre>
<p>Another solution that can be really useful if you don’t know the size of the result is to store the results in a list. A list, as opposed to a vector or a matrix, stores its elements in different places in memory (the elements don’t have to be contiguously stored in memory) so that you can add one element to the list without copying the rest of the list.</p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">gen_list &lt;-<span class="st"> </span><span class="cf">function</span>(<span class="dt">n =</span> <span class="fl">1e3</span>, <span class="dt">max =</span> <span class="dv">1</span><span class="op">:</span><span class="dv">500</span>) {
  l &lt;-<span class="st"> </span><span class="kw">list</span>()
  <span class="cf">for</span> (i <span class="cf">in</span> <span class="kw">seq_along</span>(max)) {
    l[[i]] &lt;-<span class="st"> </span><span class="kw">runif</span>(n, <span class="dt">max =</span> max[i])
  }
  <span class="kw">do.call</span>(<span class="st">&quot;cbind&quot;</span>, l)
}</code></pre></div>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">set.seed</span>(<span class="dv">1</span>)
<span class="kw">system.time</span>(mat7 &lt;-<span class="st"> </span><span class="kw">gen_list</span>(<span class="dt">max =</span> <span class="dv">1</span><span class="op">:</span><span class="dv">500</span>))</code></pre></div>
<pre><code>##    user  system elapsed 
##   0.028   0.000   0.028</code></pre>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">identical</span>(mat7, mat1)</code></pre></div>
<pre><code>## [1] TRUE</code></pre>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">system.time</span>(mat8 &lt;-<span class="st"> </span><span class="kw">gen_list</span>(<span class="dt">max =</span> <span class="dv">1</span><span class="op">:</span><span class="dv">2000</span>))</code></pre></div>
<pre><code>##    user  system elapsed 
##   0.098   0.006   0.105</code></pre>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">identical</span>(mat8, mat2)</code></pre></div>
<pre><code>## [1] TRUE</code></pre>
<p><img src="{{ site.url }}{{ site.baseurl }}/images/data-structures.jpg" width="55%" /></p>
</div>
<div id="vectorization-why" class="section level2">
<h2>Vectorization, why?</h2>
<p>I call <em>vectorized</em> a function that takes vectors as arguments and operate on each element of these vectors in another (compiled) language (such as C++ and Fortran).</p>
<p>So, let me repeat myself: <strong><code>sapply()</code> is not a vectorized function</strong>.</p>
<p>Let’s go back to vectorization, why is it so important in R? As an example, let’s compute the sum of two vectors.</p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">add_loop_prealloc &lt;-<span class="st"> </span><span class="cf">function</span>(x, y) {
  res &lt;-<span class="st"> </span><span class="kw">double</span>(<span class="kw">length</span>(x))
  <span class="cf">for</span> (i <span class="cf">in</span> <span class="kw">seq_along</span>(x)) {
    res[i] &lt;-<span class="st"> </span>x[i] <span class="op">+</span><span class="st"> </span>y[i]
  }
  res
}

add_sapply &lt;-<span class="st"> </span><span class="cf">function</span>(x, y) {
  <span class="kw">sapply</span>(<span class="kw">seq_along</span>(x), <span class="cf">function</span>(i) x[i] <span class="op">+</span><span class="st"> </span>y[i])
}

add_vectorized &lt;-<span class="st"> `</span><span class="dt">+</span><span class="st">`</span></code></pre></div>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">N &lt;-<span class="st"> </span><span class="fl">1e5</span>; x &lt;-<span class="st"> </span><span class="kw">runif</span>(N); y &lt;-<span class="st"> </span><span class="kw">rnorm</span>(N)

compiler<span class="op">::</span><span class="kw">enableJIT</span>(<span class="dv">0</span>)  ## disable just-in-time compilation</code></pre></div>
<pre><code>## [1] 3</code></pre>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">microbenchmark<span class="op">::</span><span class="kw">microbenchmark</span>(
        <span class="dt">LOOP =</span> <span class="kw">add_loop_prealloc</span>(x, y),
      <span class="dt">SAPPLY =</span> <span class="kw">add_sapply</span>(x, y),
  <span class="dt">VECTORIZED =</span> <span class="kw">add_vectorized</span>(x, y)
)</code></pre></div>
<pre><code>## Unit: microseconds
##        expr        min          lq        mean      median         uq        max neval
##        LOOP 116724.093 137378.5615 156935.0679 149568.2770 165776.978 281091.814   100
##      SAPPLY 125235.495 146122.2815 174867.8669 169495.3810 192442.822 337318.547   100
##  VECTORIZED    109.899    212.5135    247.1062    240.1635    260.046    574.126   100</code></pre>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">compiler<span class="op">::</span><span class="kw">enableJIT</span>(<span class="dv">3</span>)  ## default</code></pre></div>
<pre><code>## [1] 0</code></pre>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">microbenchmark<span class="op">::</span><span class="kw">microbenchmark</span>(
        <span class="dt">LOOP =</span> <span class="kw">add_loop_prealloc</span>(x, y),
      <span class="dt">SAPPLY =</span> <span class="kw">add_sapply</span>(x, y),
  <span class="dt">VECTORIZED =</span> <span class="kw">add_vectorized</span>(x, y)
)</code></pre></div>
<pre><code>## Unit: microseconds
##        expr       min         lq        mean      median          uq        max neval
##        LOOP  8762.638  10646.571  12672.2114  11206.1365  12772.3280  35368.977   100
##      SAPPLY 82463.586 116025.847 148921.6490 142601.9835 171450.0465 266249.684   100
##  VECTORIZED   123.004    219.397    320.1623    259.7455    384.3415    683.014   100</code></pre>
<p>Here, the vectorized function is much faster than the two others and the for-loop approach is faster than the <code>sapply</code> equivalent when just-in-time compilation is enabled.</p>
<p>As an interpreted language, for each iteration <code>res[i] &lt;- x[i] + y[i]</code>, R has to ask:</p>
<ol style="list-style-type: decimal">
<li><p>what is the type of <code>x[i]</code> and <code>y[i]</code>?</p></li>
<li><p>can I add these two types? what is the type of <code>x[i] + y[i]</code> then?</p></li>
<li><p>can I store this result in <code>res</code> or do I need to convert it?</p></li>
</ol>
<p>These questions must be answered for each iteration, which takes time. On the contrary, for vectorized functions, these questions must be answered only once, which saves a lot of time. Read more with <a href="http://www.noamross.net/blog/2014/4/16/vectorization-in-r--why.html">Noam Ross’s blog post on vectorization</a>.</p>
</div>
<div id="conclusion" class="section level2">
<h2>Conclusion</h2>
<ul>
<li><p>In this post, I don’t say that you shouldn’t use <code>lapply()</code> instead of a for-loop. Indeed, it can be more concise and clearer to use <code>lapply()</code>, but don’t expect miracles with respect to performance. You should also take a look at package {purrr} that provides shortcuts, consistency and some functions to <a href="https://www.rstudio.com/resources/webinars/thinking-inside-the-box-you-can-do-that-inside-a-data-frame/">iterate over rows of a data frame</a>.</p></li>
<li><p>Loops are slower in R than in C++ because R is an interpreted language (not compiled), even if now there is just-in-time (JIT) compilation in R (&gt;= 3.4) that makes R loops faster (yet, still not as fast). Then, R loops are not that bad if you don’t use too many iterations (let’s say not more than 100,000 iterations).</p></li>
<li><p>Beware what you’re doing in the loops because they can be super slow. Use vectorized operations if you can (search for them in available packages such as {matrixStats}). If you can’t, write your own vectorized functions with {Rcpp}. I have an introduction to {Rcpp} <a href="https://privefl.github.io/R-presentation/Rcpp.html">there</a>.</p></li>
</ul>
</div>
</section>
