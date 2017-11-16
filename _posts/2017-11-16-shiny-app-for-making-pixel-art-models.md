---
title: "Shiny App for making Pixel Art Models"

author: "Florian Privé"
date: "November 16, 2017"
layout: post
---


<section class="main-content">
<p><img src="https://i.skyrock.net/8357/92298357/pics/3238779731_1_9_0mvpuhVx.png" width="80%" style="display: block; margin: auto;" /></p>
<p>Last weekend, I discovered the pixel art. The goal is to reproduce a pixelated drawing. <strong>Anyone can do this</strong> without any drawing skills because you just have to reproduce the pixels one by one (on a squared paper). Kids and big kids can quickly become addicted to this.</p>
<div id="example" class="section level2">
<h2>Example</h2>
<p><img src="https://i.pinimg.com/564x/91/af/46/91af46f50866bc7b95e72c4b3891dc52--man--iron-man.jpg" width="30%" style="display: block; margin: auto;" /></p>
<p>For this pixelated ironman, you need only 3 colors (black, yellow and red). At the beginning I thought this would be really easy and quick. It took me approximately 15 minutes to reproduce this. Children could take more than 1 hour to reproduce this, so it’s nice if you want to keep them busy.</p>
</div>
<div id="make-your-own-pixel-art-models" class="section level2">
<h2>Make your own pixel art models</h2>
<p>On the internet, there are lots of models. There are also tutos on how to make models with Photoshop. Yet, I wanted to make an R package for making pixel art models, based on any pictures. The pipeline I came up with is the following:</p>
<ul>
<li>read an image with package <strong>magick</strong></li>
<li>downsize this image for processing</li>
<li>use K-means to project colors in a small set of colors</li>
<li>downsize the image and project colors</li>
<li>plot the pixels and add lines to separate them</li>
</ul>
<p>I think there may be a lot to improve but from what I currently know about images, it’s the best I could come up with as a first shot.</p>
<p>I made a package called <strong>pixelart</strong>, with an associated Shiny App.</p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="co"># Installation</span>
devtools::<span class="kw">install_github</span>(<span class="st">&quot;privefl/pixelart&quot;</span>)

<span class="co"># Run Shiny App</span>
pixelart::<span class="kw">run_app</span>()</code></pre></div>
<p><img src="https://raw.githubusercontent.com/privefl/pixelart/master/webshot.png" width="70%" style="display: block; margin: auto;" /></p>
</div>
</section>
