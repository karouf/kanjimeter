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
  document.getElementsByTagName('body')[0].dispatchEvent(authEvent);
};

function authenticate() {
  apikey = get_apikey_from_storage();
  if(!apikey) {
    apikey = get_apikey_from_client();
  }
  get_user(apikey);
};

function setup() {
  check_requirements();
  authenticate();
};

function createPageNode(page) {
  li = document.createElement('li');
  a = document.createElement('a');
  a.setAttribute('href', page.url);
  a.innerText = page.title;
  span = document.createElement('span');
  span.innerText = Math.round(page.rating * 100) + '%';
  li.appendChild(a);
  li.appendChild(span);
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

window.addEventListener("load", setup);
window.addEventListener("authenticated", list_pages);
