if InputCheck(INPUT_VERB.UP)
{
	y -= 1;
	PP.splitview_set_view(0, x, y);
}

if InputCheck(INPUT_VERB.DOWN)
{
	y += 1;
	PP.splitview_set_view(0, x, y);
}

if InputCheck(INPUT_VERB.LEFT)
{
	x -= 1;
	PP.splitview_set_view(0, x, y);
}

if InputCheck(INPUT_VERB.RIGHT)
{
	x += 1;
	PP.splitview_set_view(0, x, y);
}