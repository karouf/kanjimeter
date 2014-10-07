var Kanjinator = {};
var user = null;
var resscript;
var authEvent = new CustomEvent('authenticated', {details: {}, bubbles: true, cancelable: true});

function check_requirements() {
};

function get_apikey_from_storage() {
  return localStorage.getItem("wanikani_api_key");
};

function get_apikey_from_client() {
  localStorage.setItem('wanikani_api_key', window.prompt('Please enter your Wanikani API key'));
};

function get_user(apikey) {
  resscript = document.createElement("script");
  resscript.src = "https://www.wanikani.com/api/user/" + apikey + "/kanji?callback=onWaniKaniResult";
  document.body.appendChild(resscript);
};

function getKanjiForUser(data) {
  kanji = [];
  data.forEach(function(k) {
    if(k.user_specific != null) {
      if(['guru', 'master', 'enlightened', 'burned'].indexOf(k.user_specific.srs) != -1) {
        kanji.push(k.character);
      }
    }
  });
  return kanji;
};

function parseResult(data) {
  infos = data.user_information;
  infos.kanji = getKanjiForUser(data.requested_information);
  return infos;
};

function onWaniKaniResult(data) {
  document.body.removeChild(resscript);
  user = parseResult(data);
  localStorage.setItem('user', JSON.stringify(user));
  localStorage.setItem('cached', Date.now());
  document.getElementsByTagName('body')[0].dispatchEvent(authEvent);
};

function authExpired() {
  if((Date.now() - localStorage.getItem('cached')) > 86400000) {
    return true;
  } else {
    return false;
  }
};

function userCached() {
  if(localStorage.getItem('cached') != null) {
    return true;
  } else {
    return false;
  }
};

function authenticate() {
  if(authExpired() || !userCached()) {
    apikey = get_apikey_from_storage();
    if(!apikey) {
      apikey = get_apikey_from_client();
    }
    get_user(apikey);
  } else {
    user = JSON.parse(localStorage.getItem('user'));
    document.getElementsByTagName('body')[0].dispatchEvent(authEvent);
  }
};

function setup() {
  check_requirements();
  authenticate();
};

function createPageNode(page) {
  li = document.createElement('li');
  li.classList.add('page');
  a = document.createElement('a');
  a.setAttribute('href', page.url);
  a.innerText = page.title;
  a.classList.add('page__link');
  a.target = '_blank';
  span = document.createElement('span');
  span.innerText = Math.round(page.rating * 100) + '%';
  span.classList.add('page__rating');
  li.appendChild(span);
  li.appendChild(a);
  return li;
};

function display(pages) {
  pages.forEach(function(page) {
    node = createPageNode(page);
    document.getElementById('pages').appendChild(node);
  });
};

function get_data() {
  request = new XMLHttpRequest();
  request.open('POST', '/api/match');
  request.setRequestHeader("Content-Type", "application/json;charset=UTF-8");
  request.onreadystatechange = function() {
    if (request.readyState==4 && request.status==200) {
      data = JSON.parse(request.responseText);
      display(data);
    }
  }
  request.send(JSON.stringify({kanji: user.kanji.join('')}));
};

function list_pages() {
  get_data(user);
};

function updateUserDetails() {
  document.getElementsByClassName('user__gravatar')[0].src = 'https://www.gravatar.com/avatar/' + user.gravatar + '.jpg?s=200&timestamp=10062014&d=https://s3.amazonaws.com/s3.wanikani.com/default-avatar-300x300-20121121.png';
  document.getElementsByClassName('user__level')[0].innerHTML = 'Level ' + user.level;
};

window.addEventListener("load", setup);
window.addEventListener("authenticated", updateUserDetails);
window.addEventListener("authenticated", list_pages);
