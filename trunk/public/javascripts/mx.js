function test()
{
	alert("test");
}


function copyTag(src, dest)
{
	// searching first ul 
	tmp=src.getElementsByTagName("ul")[0].cloneNode(true);
	addedNode = dest.appendChild(tmp);
}


