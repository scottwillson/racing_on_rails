hoverImage = new Image(200, 24);
hoverImage.src = '/images/buttons/hover.jpg';

function hover(anchor) {
	if (anchor.parentNode.className == 'first') {
		anchor.parentNode.className = 'hover_first';
		var nextCell = anchor.parentNode.nextSibling;
		if (nextCell != null && anchor.parentNode.parentNode.parentNode.parentNode.className == 'tabs_solo') {
			nextCell.className = 'hover_last';
		}
	}
	else if (anchor.parentNode.className == 'last') {
		anchor.parentNode.className = 'hover_last';
	}
	else {
		anchor.parentNode.className = 'hover';
	}
	return false;
}

function hoverOut(anchor) {
	if (anchor.parentNode.className == 'hover_first') {
		anchor.parentNode.className = 'first';
		var nextCell = anchor.parentNode.nextSibling;
		if (nextCell != null && anchor.parentNode.parentNode.parentNode.parentNode.className == 'tabs_solo') {
			nextCell.className = 'last';
		}
	}
	else if (anchor.parentNode.className == 'hover_last') {
		anchor.parentNode.className = 'last';
	}
	else {
		anchor.parentNode.className = '';
	}
	return false;
}
