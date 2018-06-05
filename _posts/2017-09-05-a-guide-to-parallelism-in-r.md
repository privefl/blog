---
title: "A guide to parallelism in R"

author: "Florian Privé"
date: "September 5, 2017"
layout: post
---


<section class="main-content">
<p>In this post, I talk about parallelism in R. This post is likely biased towards the solutions I use. For example, I never use <code>mcapply</code> nor <code>clusterApply</code>; I prefer to always use <code>foreach</code>. In this post, we will focus on <strong>how to parallelize R code on your computer with package {foreach}</strong>.</p>
<p>In this post, I use mainly silly examples just to show one point at a time.</p>
<div id="basics-of-foreach" class="section level2">
<h2>Basics of foreach</h2>
<p>You can install R package {foreach} with <code>install.packages(&quot;foreach&quot;)</code>.</p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">library</span>(foreach)

<span class="kw">foreach</span>(<span class="dt">i =</span> <span class="dv">1</span><span class="op">:</span><span class="dv">3</span>) <span class="op">%do%</span><span class="st"> </span>{
  <span class="kw">sqrt</span>(i)
}</code></pre></div>
<pre><code>## [[1]]
## [1] 1
## 
## [[2]]
## [1] 1.414214
## 
## [[3]]
## [1] 1.732051</code></pre>
<p>In the example above, you iterate on <code>i</code> and apply the expression <code>sqrt(i)</code>. Function <code>foreach</code> returns a list by default. A common mistake is to think that <code>foreach</code> is like a for-loop. Actually, <strong><code>foreach</code> is more like <code>lapply</code></strong>.</p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">lapply</span>(<span class="dv">1</span><span class="op">:</span><span class="dv">3</span>, <span class="cf">function</span>(i) {
  <span class="kw">sqrt</span>(i)
})</code></pre></div>
<pre><code>## [[1]]
## [1] 1
## 
## [[2]]
## [1] 1.414214
## 
## [[3]]
## [1] 1.732051</code></pre>
<p>Parameter <code>.combine</code> can be very useful. Yet, now, I usually prefer to combine the results afterwards (see <code>do.call</code> below).</p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">foreach</span>(<span class="dt">i =</span> <span class="dv">1</span><span class="op">:</span><span class="dv">3</span>, <span class="dt">.combine =</span> <span class="st">&#39;c&#39;</span>) <span class="op">%do%</span><span class="st"> </span>{
  <span class="kw">sqrt</span>(i)
}</code></pre></div>
<pre><code>## [1] 1.000000 1.414214 1.732051</code></pre>
<p>With <code>lapply</code>, we would do</p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">res &lt;-<span class="st"> </span><span class="kw">lapply</span>(<span class="dv">1</span><span class="op">:</span><span class="dv">3</span>, <span class="cf">function</span>(i) {
  <span class="kw">sqrt</span>(i)
})
<span class="kw">do.call</span>(<span class="st">&#39;c&#39;</span>, res)</code></pre></div>
<pre><code>## [1] 1.000000 1.414214 1.732051</code></pre>
</div>
<div id="parallelize-with-foreach" class="section level2">
<h2>Parallelize with foreach</h2>
<p>You need to do at least two things:</p>
<ul>
<li><p>replace <code>%do%</code> by <code>%dopar%</code>. Basically, always use <code>%dopar%</code> because you can use <code>registerDoSEQ()</code> is you really want to run the <code>foreach</code> sequentially.</p></li>
<li><p>register a parallel backend using one of the packages that begin with <em>do</em> (such as <code>doParallel</code>, <code>doMC</code>, <code>doMPI</code> and more). I will list only the two main parallel backends because there are too many of them.</p></li>
</ul>
<div id="using-clusters" class="section level3">
<h3>Using clusters</h3>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="co"># Example registering clusters</span>
cl &lt;-<span class="st"> </span>parallel<span class="op">::</span><span class="kw">makeCluster</span>(<span class="dv">2</span>)
doParallel<span class="op">::</span><span class="kw">registerDoParallel</span>(cl)
<span class="kw">foreach</span>(<span class="dt">i =</span> <span class="dv">1</span><span class="op">:</span><span class="dv">3</span>, <span class="dt">.combine =</span> <span class="st">&#39;c&#39;</span>) <span class="op">%dopar%</span><span class="st"> </span>{
  <span class="kw">sqrt</span>(i)
}</code></pre></div>
<pre><code>## [1] 1.000000 1.414214 1.732051</code></pre>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">parallel<span class="op">::</span><span class="kw">stopCluster</span>(cl)</code></pre></div>
<p>In this situation, all the data and packages used must be exported (copied) to the clusters, which can add some overhead. Yet, at least, you know what you do.</p>
</div>
<div id="using-forking" class="section level3">
<h3>Using forking</h3>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">cl &lt;-<span class="st"> </span>parallel<span class="op">::</span><span class="kw">makeForkCluster</span>(<span class="dv">2</span>)
doParallel<span class="op">::</span><span class="kw">registerDoParallel</span>(cl)
<span class="kw">foreach</span>(<span class="dt">i =</span> <span class="dv">1</span><span class="op">:</span><span class="dv">3</span>, <span class="dt">.combine =</span> <span class="st">&#39;c&#39;</span>) <span class="op">%dopar%</span><span class="st"> </span>{
  <span class="kw">sqrt</span>(i)
}</code></pre></div>
<pre><code>## [1] 1.000000 1.414214 1.732051</code></pre>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">parallel<span class="op">::</span><span class="kw">stopCluster</span>(cl)</code></pre></div>
<p>Forking just copy the R session in its current state. This is very fast because it copies objects only it they are modified. Moreover, you don’t need to export variables nor packages because they are already in the session. However, <strong>this can’t be used on Windows</strong>. This is why I use the <em>clusters</em> option in my packages.</p>
</div>
</div>
<div id="common-problemsmistakesquestions" class="section level2">
<h2>Common problems/mistakes/questions</h2>
<div id="exporting-variables-and-packages" class="section level3">
<h3>Exporting variables and packages</h3>
<blockquote>
<p>“object”xxx&quot; not found&quot; or “could not find function”xxx“”.</p>
</blockquote>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="co"># Some data and function</span>
<span class="kw">library</span>(dplyr)
dfs &lt;-<span class="st"> </span><span class="kw">rep</span>(<span class="kw">list</span>(iris), <span class="dv">3</span>)
<span class="kw">count</span>(dfs[[<span class="dv">1</span>]], Species)</code></pre></div>
<pre><code>## # A tibble: 3 x 2
##   Species        n
##   &lt;fct&gt;      &lt;int&gt;
## 1 setosa        50
## 2 versicolor    50
## 3 virginica     50</code></pre>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="co"># Sequential processing to apply to </span>
<span class="co"># all the data frames of the list &#39;dfs&#39;</span>
<span class="kw">registerDoSEQ</span>()
myFun &lt;-<span class="st"> </span><span class="cf">function</span>() {
  <span class="kw">foreach</span>(<span class="dt">i =</span> <span class="kw">seq_along</span>(dfs)) <span class="op">%dopar%</span><span class="st"> </span>{
    df &lt;-<span class="st"> </span>dfs[[i]]
    <span class="kw">count</span>(df, Species)
  }
}
<span class="kw">str</span>(<span class="kw">myFun</span>())</code></pre></div>
<pre><code>## List of 3
##  $ :Classes &#39;tbl_df&#39;, &#39;tbl&#39; and &#39;data.frame&#39;:    3 obs. of  2 variables:
##   ..$ Species: Factor w/ 3 levels &quot;setosa&quot;,&quot;versicolor&quot;,..: 1 2 3
##   ..$ n      : int [1:3] 50 50 50
##  $ :Classes &#39;tbl_df&#39;, &#39;tbl&#39; and &#39;data.frame&#39;:    3 obs. of  2 variables:
##   ..$ Species: Factor w/ 3 levels &quot;setosa&quot;,&quot;versicolor&quot;,..: 1 2 3
##   ..$ n      : int [1:3] 50 50 50
##  $ :Classes &#39;tbl_df&#39;, &#39;tbl&#39; and &#39;data.frame&#39;:    3 obs. of  2 variables:
##   ..$ Species: Factor w/ 3 levels &quot;setosa&quot;,&quot;versicolor&quot;,..: 1 2 3
##   ..$ n      : int [1:3] 50 50 50</code></pre>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="co"># Try in parallel</span>
cl &lt;-<span class="st"> </span>parallel<span class="op">::</span><span class="kw">makeCluster</span>(<span class="dv">2</span>)
doParallel<span class="op">::</span><span class="kw">registerDoParallel</span>(cl)
<span class="kw">tryCatch</span>(<span class="kw">myFun</span>(), <span class="dt">error =</span> <span class="cf">function</span>(e) <span class="kw">print</span>(e))</code></pre></div>
<pre><code>## &lt;simpleError in {    df &lt;- dfs[[i]]    count(df, Species)}: task 1 failed - &quot;objet &#39;dfs&#39; introuvable&quot;&gt;</code></pre>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">parallel<span class="op">::</span><span class="kw">stopCluster</span>(cl)</code></pre></div>
<p>Why doesn’t this work anymore? <code>foreach</code> will export all the needed variables that are present in its environment (here, the environment of <code>myFun</code>) and <code>dfs</code> is not in this environment. Some will tell you to use option <code>.export</code> of <code>foreach</code> but I don’t think it’s good practice. You just have to pass <code>dfs</code> to <code>myFun</code>.</p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">myFun2 &lt;-<span class="st"> </span><span class="cf">function</span>(dfs) {
  <span class="kw">foreach</span>(<span class="dt">i =</span> <span class="kw">seq_along</span>(dfs)) <span class="op">%dopar%</span><span class="st"> </span>{
    df &lt;-<span class="st"> </span>dfs[[i]]
    <span class="kw">count</span>(df, Species)
  }
}
<span class="co"># Try in parallel</span>
cl &lt;-<span class="st"> </span>parallel<span class="op">::</span><span class="kw">makeCluster</span>(<span class="dv">2</span>)
doParallel<span class="op">::</span><span class="kw">registerDoParallel</span>(cl)
<span class="kw">tryCatch</span>(<span class="kw">myFun2</span>(dfs), <span class="dt">error =</span> <span class="cf">function</span>(e) <span class="kw">print</span>(e))</code></pre></div>
<pre><code>## &lt;simpleError in {    df &lt;- dfs[[i]]    count(df, Species)}: task 1 failed - &quot;impossible de trouver la fonction &quot;count&quot;&quot;&gt;</code></pre>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">parallel<span class="op">::</span><span class="kw">stopCluster</span>(cl)</code></pre></div>
<p>This still doesn’t work. You also need to load packages. You could use option <code>.packages</code> of <code>foreach</code> but you could simply add <code>dplyr::</code> before <code>count</code>. Moreover, it is clearer (like one does in packages).</p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">myFun3 &lt;-<span class="st"> </span><span class="cf">function</span>(dfs) {
  <span class="kw">foreach</span>(<span class="dt">i =</span> <span class="kw">seq_along</span>(dfs)) <span class="op">%dopar%</span><span class="st"> </span>{
    df &lt;-<span class="st"> </span>dfs[[i]]
    dplyr<span class="op">::</span><span class="kw">count</span>(df, Species)
  }
}
<span class="co"># Try in parallel</span>
cl &lt;-<span class="st"> </span>parallel<span class="op">::</span><span class="kw">makeCluster</span>(<span class="dv">2</span>)
doParallel<span class="op">::</span><span class="kw">registerDoParallel</span>(cl)
<span class="kw">tryCatch</span>(<span class="kw">myFun3</span>(dfs), <span class="dt">error =</span> <span class="cf">function</span>(e) <span class="kw">print</span>(e))</code></pre></div>
<pre><code>## [[1]]
## # A tibble: 3 x 2
##   Species        n
##   &lt;fct&gt;      &lt;int&gt;
## 1 setosa        50
## 2 versicolor    50
## 3 virginica     50
## 
## [[2]]
## # A tibble: 3 x 2
##   Species        n
##   &lt;fct&gt;      &lt;int&gt;
## 1 setosa        50
## 2 versicolor    50
## 3 virginica     50
## 
## [[3]]
## # A tibble: 3 x 2
##   Species        n
##   &lt;fct&gt;      &lt;int&gt;
## 1 setosa        50
## 2 versicolor    50
## 3 virginica     50</code></pre>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">parallel<span class="op">::</span><span class="kw">stopCluster</span>(cl)</code></pre></div>
</div>
<div id="iterate-over-lots-of-elements." class="section level3">
<h3>Iterate over lots of elements.</h3>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">cl &lt;-<span class="st"> </span>parallel<span class="op">::</span><span class="kw">makeCluster</span>(<span class="dv">2</span>)
doParallel<span class="op">::</span><span class="kw">registerDoParallel</span>(cl)
<span class="kw">system.time</span>(
  <span class="kw">foreach</span>(<span class="dt">i =</span> <span class="kw">seq_len</span>(<span class="fl">2e4</span>), <span class="dt">.combine =</span> <span class="st">&#39;c&#39;</span>) <span class="op">%dopar%</span><span class="st"> </span>{
    <span class="kw">sqrt</span>(i)
  }
)</code></pre></div>
<pre><code>##    user  system elapsed 
##   6.681   0.479   7.611</code></pre>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">parallel<span class="op">::</span><span class="kw">stopCluster</span>(cl)</code></pre></div>
<p>Iterating over multiple elements in R is bad for performance. Moreover, <code>foreach</code> is only combining results 100 by 100, which also slows computations.</p>
<p>If there are too many elements to loop over, the best is to split the computation in <em>ncores</em> blocks and to perform some optimized sequential work on each block. In package {bigstatsr}, I use the following function to split indices in <code>nb</code> groups because I often need to iterate over hundreds of thousands of elements (columns).</p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">bigstatsr<span class="op">:::</span>CutBySize</code></pre></div>
<pre><code>## function (m, block.size, nb = ceiling(m/block.size)) 
## {
##     if (nb &gt; m) 
##         nb &lt;- m
##     int &lt;- m/nb
##     upper &lt;- round(1:nb * int)
##     lower &lt;- c(1, upper[-nb] + 1)
##     size &lt;- c(upper[1], diff(upper))
##     cbind(lower, upper, size)
## }
## &lt;bytecode: 0xad02c80&gt;
## &lt;environment: namespace:bigstatsr&gt;</code></pre>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">bigstatsr<span class="op">:::</span><span class="kw">CutBySize</span>(<span class="dv">20</span>, <span class="dt">nb =</span> <span class="dv">3</span>)</code></pre></div>
<pre><code>##      lower upper size
## [1,]     1     7    7
## [2,]     8    13    6
## [3,]    14    20    7</code></pre>
</div>
<div id="filling-something-in-parallel" class="section level3">
<h3>Filling something in parallel</h3>
<blockquote>
<p>Using foreach loop in R returning NA</p>
</blockquote>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">mat &lt;-<span class="st"> </span><span class="kw">matrix</span>(<span class="dt">nrow =</span> <span class="dv">5</span>, <span class="dt">ncol =</span> <span class="dv">8</span>)
<span class="kw">registerDoSEQ</span>()
<span class="co"># Nested foreach loop</span>
tmp &lt;-<span class="st"> </span><span class="kw">foreach</span>(<span class="dt">j =</span> <span class="dv">1</span><span class="op">:</span><span class="dv">8</span>) <span class="op">%:%</span><span class="st"> </span><span class="kw">foreach</span>(<span class="dt">i =</span> <span class="dv">1</span><span class="op">:</span><span class="dv">5</span>) <span class="op">%dopar%</span><span class="st"> </span>{
  mat[i, j] &lt;-<span class="st"> </span>i <span class="op">+</span><span class="st"> </span>j
}
mat</code></pre></div>
<pre><code>##      [,1] [,2] [,3] [,4] [,5] [,6] [,7] [,8]
## [1,]    2    3    4    5    6    7    8    9
## [2,]    3    4    5    6    7    8    9   10
## [3,]    4    5    6    7    8    9   10   11
## [4,]    5    6    7    8    9   10   11   12
## [5,]    6    7    8    9   10   11   12   13</code></pre>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="co"># Try in parallel</span>
mat2 &lt;-<span class="st"> </span><span class="kw">matrix</span>(<span class="dt">nrow =</span> <span class="dv">5</span>, <span class="dt">ncol =</span> <span class="dv">8</span>)
cl &lt;-<span class="st"> </span>parallel<span class="op">::</span><span class="kw">makeCluster</span>(<span class="dv">2</span>)
doParallel<span class="op">::</span><span class="kw">registerDoParallel</span>(cl)
tmp2 &lt;-<span class="st"> </span><span class="kw">foreach</span>(<span class="dt">j =</span> <span class="dv">1</span><span class="op">:</span><span class="dv">8</span>) <span class="op">%:%</span><span class="st"> </span><span class="kw">foreach</span>(<span class="dt">i =</span> <span class="dv">1</span><span class="op">:</span><span class="dv">5</span>) <span class="op">%dopar%</span><span class="st"> </span>{
  mat2[i, j] &lt;-<span class="st"> </span>i <span class="op">+</span><span class="st"> </span>j
}
parallel<span class="op">::</span><span class="kw">stopCluster</span>(cl)
mat2</code></pre></div>
<pre><code>##      [,1] [,2] [,3] [,4] [,5] [,6] [,7] [,8]
## [1,]   NA   NA   NA   NA   NA   NA   NA   NA
## [2,]   NA   NA   NA   NA   NA   NA   NA   NA
## [3,]   NA   NA   NA   NA   NA   NA   NA   NA
## [4,]   NA   NA   NA   NA   NA   NA   NA   NA
## [5,]   NA   NA   NA   NA   NA   NA   NA   NA</code></pre>
<p>There are two problems here:</p>
<ol style="list-style-type: decimal">
<li><p><code>mat</code> is filled in the sequential version but won’t be in the parallel version. This is because when using parallelism, <code>mat</code> is copied so that each core modifies a copy of the matrix, not the original one.</p></li>
<li><p><code>foreach</code> returns something (here a two-level list).</p></li>
</ol>
<p>To overcome this problem, you could use shared-memory. For example, with <a href="https://github.com/privefl/bigstatsr">my package {bigstatsr}</a>.</p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">library</span>(bigstatsr)
mat3 &lt;-<span class="st"> </span><span class="kw">FBM</span>(<span class="dv">5</span>, <span class="dv">8</span>)
cl &lt;-<span class="st"> </span>parallel<span class="op">::</span><span class="kw">makeCluster</span>(<span class="dv">2</span>)
doParallel<span class="op">::</span><span class="kw">registerDoParallel</span>(cl)
tmp3 &lt;-<span class="st"> </span><span class="kw">foreach</span>(<span class="dt">j =</span> <span class="dv">1</span><span class="op">:</span><span class="dv">8</span>, <span class="dt">.combine =</span> <span class="st">&#39;c&#39;</span>) <span class="op">%:%</span>
<span class="st">  </span><span class="kw">foreach</span>(<span class="dt">i =</span> <span class="dv">1</span><span class="op">:</span><span class="dv">5</span>, <span class="dt">.combine =</span> <span class="st">&#39;c&#39;</span>) <span class="op">%dopar%</span><span class="st"> </span>{
    mat3[i, j] &lt;-<span class="st"> </span>i <span class="op">+</span><span class="st"> </span>j
    <span class="ot">NULL</span>
  }
parallel<span class="op">::</span><span class="kw">stopCluster</span>(cl)
mat3[]</code></pre></div>
<pre><code>##      [,1] [,2] [,3] [,4] [,5] [,6] [,7] [,8]
## [1,]    2    3    4    5    6    7    8    9
## [2,]    3    4    5    6    7    8    9   10
## [3,]    4    5    6    7    8    9   10   11
## [4,]    5    6    7    8    9   10   11   12
## [5,]    6    7    8    9   10   11   12   13</code></pre>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">tmp3</code></pre></div>
<pre><code>## NULL</code></pre>
<p>The original matrix is now modified. Note that I return <code>NULL</code> to save memory.</p>
</div>
<div id="parallelize-over-a-large-matrix" class="section level3">
<h3>Parallelize over a large matrix</h3>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">mat &lt;-<span class="st"> </span><span class="kw">matrix</span>(<span class="dv">0</span>, <span class="fl">1e4</span>, <span class="fl">1e4</span>); mat[] &lt;-<span class="st"> </span><span class="kw">rnorm</span>(<span class="kw">length</span>(mat))
cl &lt;-<span class="st"> </span>parallel<span class="op">::</span><span class="kw">makeCluster</span>(<span class="dv">2</span>)
doParallel<span class="op">::</span><span class="kw">registerDoParallel</span>(cl)
<span class="kw">system.time</span>(
  tmp &lt;-<span class="st"> </span><span class="kw">foreach</span>(<span class="dt">k =</span> <span class="dv">1</span><span class="op">:</span><span class="dv">2</span>, <span class="dt">.combine =</span> <span class="st">&#39;c&#39;</span>) <span class="op">%dopar%</span><span class="st"> </span>{
    <span class="kw">Sys.sleep</span>(<span class="dv">1</span>)
    mat[<span class="dv">1</span>, <span class="dv">1</span>]
  }
)</code></pre></div>
<pre><code>##    user  system elapsed 
##   1.931   0.323   4.517</code></pre>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">parallel<span class="op">::</span><span class="kw">stopCluster</span>(cl)</code></pre></div>
<p>If using <em>clusters</em>, copying <code>mat</code> to both clusters takes time (and memory!).</p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">mat2 &lt;-<span class="st"> </span><span class="kw">FBM</span>(<span class="fl">1e4</span>, <span class="fl">1e4</span>); mat2[] &lt;-<span class="st"> </span><span class="kw">rnorm</span>(<span class="kw">length</span>(mat2))
cl &lt;-<span class="st"> </span>parallel<span class="op">::</span><span class="kw">makeCluster</span>(<span class="dv">2</span>)
doParallel<span class="op">::</span><span class="kw">registerDoParallel</span>(cl)
<span class="kw">system.time</span>(
  tmp &lt;-<span class="st"> </span><span class="kw">foreach</span>(<span class="dt">k =</span> <span class="dv">1</span><span class="op">:</span><span class="dv">2</span>, <span class="dt">.combine =</span> <span class="st">&#39;c&#39;</span>) <span class="op">%dopar%</span><span class="st"> </span>{
    <span class="kw">Sys.sleep</span>(<span class="dv">1</span>)
    mat2[<span class="dv">1</span>, <span class="dv">1</span>]
  }
)</code></pre></div>
<pre><code>##    user  system elapsed 
##   0.015   0.010   2.998</code></pre>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">parallel<span class="op">::</span><span class="kw">stopCluster</span>(cl)</code></pre></div>
<p>This is faster because it’s using a matrix that is stored on disk (so shared between processes) so that it doesn’t need to be copied.</p>
</div>
<div id="advanced-parallelism-synchronization" class="section level3">
<h3>Advanced parallelism: synchronization</h3>
<p>For example, you may need to write to the same data (maybe increment it). In this case, it is important to use some locks so that only one session writes to the data at the same time. For that, you could use package {flock}, which is really easy to use.</p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">mat &lt;-<span class="st"> </span><span class="kw">FBM</span>(<span class="dv">1</span>, <span class="dv">1</span>, <span class="dt">init =</span> <span class="dv">0</span>)
mat[]</code></pre></div>
<pre><code>## [1] 0</code></pre>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">cl &lt;-<span class="st"> </span>parallel<span class="op">::</span><span class="kw">makeCluster</span>(<span class="dv">2</span>)
doParallel<span class="op">::</span><span class="kw">registerDoParallel</span>(cl)
<span class="kw">foreach</span>(<span class="dt">k =</span> <span class="dv">1</span><span class="op">:</span><span class="dv">10</span>, <span class="dt">.combine =</span> <span class="st">&#39;c&#39;</span>) <span class="op">%dopar%</span><span class="st"> </span>{
  mat[<span class="dv">1</span>, <span class="dv">1</span>] &lt;-<span class="st"> </span>mat[<span class="dv">1</span>, <span class="dv">1</span>] <span class="op">+</span><span class="st"> </span>k
  <span class="ot">NULL</span>
}</code></pre></div>
<pre><code>## NULL</code></pre>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">parallel<span class="op">::</span><span class="kw">stopCluster</span>(cl)
mat[]</code></pre></div>
<pre><code>## [1] 34</code></pre>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">sum</span>(<span class="dv">1</span><span class="op">:</span><span class="dv">10</span>)</code></pre></div>
<pre><code>## [1] 55</code></pre>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">lock &lt;-<span class="st"> </span><span class="kw">tempfile</span>()
mat2 &lt;-<span class="st"> </span><span class="kw">FBM</span>(<span class="dv">1</span>, <span class="dv">1</span>, <span class="dt">init =</span> <span class="dv">0</span>)
mat2[]</code></pre></div>
<pre><code>## [1] 0</code></pre>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">cl &lt;-<span class="st"> </span>parallel<span class="op">::</span><span class="kw">makeCluster</span>(<span class="dv">2</span>)
doParallel<span class="op">::</span><span class="kw">registerDoParallel</span>(cl)
<span class="kw">foreach</span>(<span class="dt">k =</span> <span class="dv">1</span><span class="op">:</span><span class="dv">10</span>, <span class="dt">.combine =</span> <span class="st">&#39;c&#39;</span>) <span class="op">%dopar%</span><span class="st"> </span>{
  locked &lt;-<span class="st"> </span>flock<span class="op">::</span><span class="kw">lock</span>(lock)
  mat2[<span class="dv">1</span>, <span class="dv">1</span>] &lt;-<span class="st"> </span>mat2[<span class="dv">1</span>, <span class="dv">1</span>] <span class="op">+</span><span class="st"> </span>k
  flock<span class="op">::</span><span class="kw">unlock</span>(locked)
  <span class="ot">NULL</span>
}</code></pre></div>
<pre><code>## NULL</code></pre>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">parallel<span class="op">::</span><span class="kw">stopCluster</span>(cl)
mat2[]</code></pre></div>
<pre><code>## [1] 55</code></pre>
<p>So each process uses some lock to perform its incrementation so that the data can’t be changed by some other process in the meantime.</p>
<p>Moreover, you may also need to use some message passing or some barriers. For that, you could learn to use MPI. For some basic use, I “reimplemented” this using only shared-memory matrices (FBMs). You can see <a href="https://github.com/privefl/bigstatsr/blob/master/R/randomSVD.R#L4-L91">this function</a> is you’re interested.</p>
</div>
</div>
<div id="miscellenaous" class="section level2">
<h2>Miscellenaous</h2>
<ul>
<li><p>Recall that you won’t gain much from parallelism. You’re likely to gain much more performance by simply optimizing your sequential code. Don’t reproduce the silly examples here as real code, they are quite bad.</p></li>
<li><p>How to print during parallel execution? Use option <code>outfile</code> in <code>makeCluster</code> (for example, using <code>outfile = &quot;&quot;</code> will redirect to the console).</p></li>
<li><p>Don’t try to parallelize huge matrix operations with loops. There are already (parallel) optimized linear algebra libraries that exist and which will be much faster. For example, you could use <a href="https://mran.microsoft.com/open/">Microsoft R Open</a>.</p></li>
<li><p>Some will tell you to use <code>parallel::detectCores() - 1</code> cores. I use <code>bigstatsr::nb_cores()</code>.</p></li>
</ul>
</div>
<div id="conclusion" class="section level2">
<h2>Conclusion</h2>
<p>Hope this can help some.</p>
<p>Don’t hesitate to comment if you want to add/modify something to this post.</p>
</div>
</section>
