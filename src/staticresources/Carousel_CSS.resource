.wrapper *{
    margin:0;
    padding:0;
}

.loader{
    width:70px;
    height:70px;
    position:fixed;
    top:50%;
    left:50%;
    margin:-35px 0px 0px -35px;
    opacity:0.7;
    z-index:1000;
    background:#fff url("{!URLFOR($Resource.Carousel_Images, 'mclabs/loader.gif')}") no-repeat center center;
}

/* Preview Slider Gallery Style */
.ps_container{
    display:none;
    width:450px;
    height:300px;
    margin:10px auto 0px auto;
    position:relative;
}
.ps_image_wrapper{
    width:450px;
    height:350px;
    overflow:hidden;
    position:relative;
    margin: 0 0 0 50px;
}
.ps_image_wrapper img{
    position:absolute;
    left:0px;
    top:0px;
}
.ps_prev,
.ps_next{
    width:31px;
    height:31px;
    position:absolute;
    top:50%;
    margin-top:-40px;
    cursor:pointer;
    opacity:0.5;
	-webkit-user-select: none;
    -khtml-user-select: none;
    -moz-user-select: none;
	-o-user-select: none;
	user-select: none;
}
.ps_prev{
    background:transparent url("{!URLFOR($Resource.Carousel_Images, 'mclabs/icon_arrow_left.png')}") no-repeat top center;
    <!--left:-50px;-->
}
.ps_next{
    background:transparent url("{!URLFOR($Resource.Carousel_Images, 'mclabs/icon_arrow_right.png')}") no-repeat top center;
    right:-15px;
}
.ps_prev:hover,
.ps_next:hover{
    opacity:0.9;
}
ul.ps_nav{
    list-style:none;
    margin:0;
    padding:0;
    width:300px;
    margin:20px auto;
    position:relative;
}
ul.ps_nav li{
    float:left;
}
ul.ps_nav li a{
    display:block;
    text-indent:-9000px;
    width:11px;
    height:11px;
    outline:none;
    padding:0px 3px;
    background:transparent url("{!URLFOR($Resource.Carousel_Images, 'mclabs/dot.png')}") no-repeat top center;
}
ul.ps_nav li a:hover,ul.ps_nav li.selected a{
    background-position:50% -11px;
}
ul.ps_nav li.ps_preview{
    display:none;
    width:85px;
    height:91px;
    top:-95px;
    left:-34.5px; /*First item, next ones is leftDot - 0.5*wThis + 0.5*wDot, i.e. second one is (16 - 42.5 + 8) = -18.5 */
    position:absolute;
}
ul.ps_nav li.ps_preview span{
    background:transparent url("{!URLFOR($Resource.Carousel_Images, 'mclabs/triangle.png')}") no-repeat top center;
    width:15px;
    height:6px;
    position:absolute;
    top:85px;
    left:35px;
}
.ps_preview_wrapper{
    width:75px;
    height:75px;
    border:5px solid #fff;
    overflow:hidden;
    position:relative;
}
.ps_preview_wrapper img{
    position:absolute;
    top:0px;
    left:0px;
    max-width: 100%;
    max-height: 100%;
    }
.wrapper ul li {
    margin: 5px;
}        
      