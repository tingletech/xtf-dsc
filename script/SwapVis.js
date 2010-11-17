//////////////////////////////////////////////////////////////////////////////
//
// SwapVis: Handle swapping the visibility of two items (e.g. for dynamic
// expansion of FRBR search result).
//
//////////////////////////////////////////////////////////////////////////////

function swapVis(id1, id2)
{
    var el1 = document.getElementById(id1);
    var el2 = document.getElementById(id2);
    if (el1.style.visibility == 'hidden') {
    alert('reverse');
        var tmp = el1;
        el1 = el2;
        el2 = tmp;
    }
    
    el1.style.visibility='hidden';
    el1.style.height = '0';
    el2.style.visibility='visible';
    el2.style.height = '';
}
