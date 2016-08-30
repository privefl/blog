---
title:  "A website and blog for R users"
author: "Florian Privé"
date: "August 19, 2016"
layout: post
---



<section class="main-content">
<p>In this post, I will show you how to quickly create your website, blog and first posts. This is designed <strong>for R users only</strong>.</p>
<div id="philosophy" class="section level2">
<h2>Philosophy</h2>
<ul>
<li>This had to be free.</li>
<li>This had to be easy.</li>
<li>This had to only need RStudio and GitHub.</li>
<li><strong>Every content had to be previewable from RStudio.</strong></li>
</ul>
<div id="the-website" class="section level3">
<h3>The website</h3>
<p>Follow <a href="https://github.com/privefl/rmarkdown-website-template#make-your-website-with-r-markdown-in-minutes">this tutorial</a> to create your own website in minutes.</p>
<p>I chose not to use a Jekyll-based template for the website because</p>
<ul>
<li>you would need to configure a local install of Jekyll to preview your website,</li>
<li>using R Markdown to create your website is only natural for an R user.</li>
</ul>
<p>Thanks RStudio and GitHub pages!</p>
</div>
<div id="the-blog-and-first-posts" class="section level3">
<h3>The blog and first posts</h3>
<p>Follow <a href="https://github.com/privefl/jekyll-now-r-template#add-a-blog-to-your-website-in-minutes">this tutorial</a> to create your own blog and get your first posts in minutes.</p>
<p>I chose to use the <a href="https://github.com/barryclark/jekyll-now">Jekyll Now template</a>. I extended it so that posts have a similar rendering as an <a href="http://statr.me/2016/08/creating-pretty-documents-with-the-prettydoc-package/">HTML Pretty Document</a> with theme “cayman” and highlight “github”. I also created a function called <code>FormatPost</code> to convert your R Markdown documents in your future posts.</p>
<p>Essentially,</p>
<ul>
<li>you create an R Markdown document from the template of package prettyjekyll,</li>
<li>you preview it as an HTML Pretty Document with RStudio’s knit button,</li>
<li>when you are happy with the result, you use <code>FormatPost</code> on the Rmd file,</li>
<li>you commit and push the changes from RStudio,</li>
<li>you go see your post on your blog.</li>
</ul>
</div>
<div id="explanation" class="section level3">
<h3>Explanation</h3>
<p>The <code>FormatPost</code> function takes the main content of the HTML pretty document, puts it in some Markdown file with some YAML header. It also takes care of images’ and figures’ paths (note that caching is not supported).</p>
</div>
</div>
<div id="examples" class="section level2">
<h2>Examples</h2>
<p>You can see for example <a href="https://privefl.github.io/">my own website</a>.</p>
<p>For example of posts,</p>
<ul>
<li>see <a href="https://privefl.github.io/blog/R-package-primefactr/">this post</a> and what was <a href="https://htmlpreview.github.io/?https://github.com/privefl/blog/blob/gh-pages/_knitr/post-primefactr.html">its html preview in RStudio</a>.</li>
<li>see also <a href="https://htmlpreview.github.io/?https://github.com/privefl/blog/blob/gh-pages/_knitr/post-webpage-blog.html">the html preview of this post</a>.</li>
</ul>
<p>Pretty close, no?</p>
</div>
</section>
