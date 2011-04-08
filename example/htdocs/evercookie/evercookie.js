/*
 * Based on 'evercookie' by samy kamkar : code@samy.pl : http://samy.pl
*/

var DEBUG = location.search.substring(1).match(/^debug/);

function log () {
    if (DEBUG) {
        var args = (arguments.length > 1) ? Array.prototype.join.call(arguments, " ") : arguments[0];
        console.log(args);
    }
}

function Evercookie(options) {
    var self = this;

    self.transports = [];

    self.ready = function(cb) {
        self._ready = cb;
    };

    self.get = function(name, cb) {
        var value;

        var values = {};

        for (var i = 0; i < self.transports.length; i++) {
            var transport = self.transports[i];
            transport.get(name, function(transport, value) {
                values[transport] = value;
            });
        }

        var retries = 50;
        var join = function() {
            var size = 0;
            for (var k in values) {
                size++;
            }
            if (size == self.transports.length) {
                cb(self.pickBestValue(values));
            }
            else {
                log('Waiting... (' + size + '/' + self.transports.length+ ')');
                retries--;

                if (retries) {
                    setTimeout(join, 100);
                }
                else {
                    log('Timeout');
                    cb(value);
                }
            }
        };

        setTimeout(join, 100);
    };

    self.set = function(name, value) {
        for (var i = 0; i < self.transports.length; i++) {
            var transport = self.transports[i];
            transport.set(name, value);
        }
    };

    self.pickBestValue = function(values) {
        if (DEBUG) {
            log($.dump(values));
        }

        log('Guessing the best value...');

        var score = {};
        for (var k in values) {
            if (!values[k])
                continue;

            if (!score[values[k]])
                score[values[k]] = 0;

            score[values[k]]++;
        }

        var max = {name: '', value: 0};
        for (var k in score) {
            if (score[k] > max.value) {
                max.name = k;
                max.value = score[k];
            }
        }

        log("The best value is '" + max.name + "'");

        return max.name;
    };

    self.init = function() {
        self.transports.push(new EvercookieCache());
        self.transports.push(new EvercookieEtag());
        self.transports.push(new EvercookiePng());
        self.transports.push(new EvercookieCookie());
        self.transports.push(new EvercookieWindowName());
        self.transports.push(new EvercookieSessionStorage());
        self.transports.push(new EvercookieLocalStorage());
        self.transports.push(new EvercookieGlobalStorage());

        if (EvercookieDatabaseStorage.isSupported()) {
            self.transports.push(new EvercookieDatabaseStorage());
        }

        if (EvercookieUserdata.isSupported()) {
            self.transports.push(new EvercookieUserdata());
        }

        if (EvercookieLSO.isSupported()) {
            self.transports.push(new EvercookieLSO());
        }

        $(window).load(function() {
            self._ready();
        });
    };

    self.init();
}

function EvercookieCache() {
    var self = this;

    self.getName = function() { return 'cache'; };

    self.url = '/evercookie/cache';
    self.cookie_name = 'evercookie_cache';

    self.get = function(name, cb) {
        var cookie_value = $.cookie(self.cookie_name);
        $.cookie(self.cookie_name, null);

        $.ajax({
            url: self.url + '?name=' + name,
            success: function(data) {
                $.cookie(self.cookie_name, cookie_value, {expires: 3600});

                cb(self.getName(), data);
            },
            error: function() {
                cb(self.getName(), undefined);
            }
        });
    };

    self.set = function(name, value) {
        $.cookie(self.cookie_name, value);

        var img = new Image();
        $(img)
            .attr('style', 'visibility:hidden;position:absolute')
            .attr('src', self.url + '?name=' + name);
    };
}

function EvercookieEtag() {
    var self = this;

    self.getName = function() { return 'etag'; };

    self.cookie_name = 'evercookie_etag';
    self.url = '/evercookie/etag';

    self.get = function(name, cb) {
        var cookie_value = $.cookie(self.cookie_name);
        $.cookie(self.cookie_name, null);

        $.ajax({
            url: self.url + '?name=' + name,
            success: function(data) {
                $.cookie(self.cookie_name, cookie_value, {expires: 3600});

                cb(self.getName(), data);
            },
            error: function() {
                cb(self.getName(), undefined);
            }
        });
    };

    self.set = function(name, value) {
        $.cookie(self.cookie_name, value);

        var img = new Image();
        $(img)
            .attr('style', 'visibility:hidden;position:absolute')
            .attr('src', self.url + '?name=' + name);
    };
}

function EvercookiePng() {
    var self = this;

    self.getName = function() { return 'png'; };

    self.url = '/evercookie/png';
    self.cookie_name = 'evercookie_png';

    self.get = function(name, cb) {
        var value;

        var cookie_value = $.cookie(self.cookie_name);
        $.cookie(self.cookie_name, null);

        var ctx = self._prepareCanvas();

        var img = new Image();
        $(img)
            .attr('style', 'visibility:hidden;position:absolute')
            .attr('src', self.url + '?name=' + name)
            .load(function() {
                $.cookie(self.cookie_name, cookie_value, {expires: 3600});

                ctx.drawImage(img,0,0);

                var imgd = ctx.getImageData(0, 0, 200, 1);
                var pix = imgd.data;

                value = '';
                for (var i = 0, n = pix.length; i < n; i += 4) {
                    if (pix[i  ] == 0) break;

                    value += String.fromCharCode(pix[i]);

                    if (pix[i+1] == 0) break;

                    value += String.fromCharCode(pix[i+1]);

                    if (pix[i+2] == 0) break;

                    value += String.fromCharCode(pix[i+2]);
                }

                cb(self.getName(), value);
            })
            .error(function() {
                cb(self.getName(), undefined);
            });
    };

    self.set = function(name, value) {
        $.cookie(self.cookie_name, value);

        var img = new Image();
        $(img)
            .attr('style', 'visibility:hidden;position:absolute')
            .attr('src', self.url + '?name=' + name);
    };

    self._prepareCanvas = function() {
        var context = document.createElement('canvas');
        $(context)
            .attr('style', 'visibility:hidden;position:absolute')
            .width(200)
            .height(1);
        return context.getContext('2d');
    };
}

function EvercookieCookie() {
    var self = this;

    self.getName = function() { return 'cookie'; };

    self.get = function(name, cb) {
        cb(self.getName(), $.cookie(name));
    };

    self.set = function(name, value) {
        $.cookie(name, value, {expires: 3600});
    };
}

function EvercookieWindowName() {
    var self = this;

    self.getName = function() { return 'window'; };

    self.get = function(name, cb) {
        var value;

        try {
            var json = JSON.parse(window.name);
            value = json.name;
        }
        catch(e) {
        };

        cb(self.getName(), value);
    };

    self.set = function(name, value) {
        try {
            var stringy = JSON.stringify({name: value});
            window.name = stringy;
        }
        catch(e) {
        };
    };
}

function EvercookieUserdata() {
    var self = this;

    self.getName = function() { return 'userData'; };

    self._prepareElement = function() {
        var div = document.createElement('div');
        $(div)
            .attr('id', 'userdata_el')
            .attr('style', 'behavior:url(#default#userData)')
        document.body.appendChild(div);
        return div;
    };

    self.element = self._prepareElement();

    self.get = function(name, cb) {
        var value;

        var el = self.element;

        try {
            el.load(name);
            value = el.getAttribute(name);
        }
        catch(e) {
        };

        cb(self.getName(), value);
    };

    self.set = function(name, value) {
        var el = self.element;
        try {
            el.setAttribute(name, value);
            el.save(name);
        }
        catch(e) {
        };
    };
}

EvercookieUserdata.isSupported = function() {
    var ua = navigator.userAgent.toLowerCase();
    return ua.match(/msie/i);
}

function EvercookieSessionStorage() {
    var self = this;

    self.getName = function() { return 'sessionStorage'; };

    self.get = function(name, cb) {
        var value;

        try {
            value = sessionStorage.getItem(name);
        }
        catch(e) {
        };

        cb(self.getName(), value);
    };

    self.set = function(name, value) {
        try {
            sessionStorage.setItem(name, value);
        }
        catch(e) {
        };
    };
}

function EvercookieLocalStorage() {
    var self = this;

    self.getName = function() { return 'localStorage'; };

    self.get = function(name, cb) {
        var value;

        try {
            value = localStorage.getItem(name);
        }
        catch(e) {
        };

        cb(self.getName(), value);
    };

    self.set = function(name, value) {
        try {
            localStorage.setItem(name, value);
        }
        catch(e) {
        };
    };
}

function EvercookieGlobalStorage() {
    var self = this;

    self.getName = function() { return 'globalStorage'; };

    self.getHost = function() {
        var host = location.hostname;
        return host;
    };

    self.get = function(name, cb) {
        var value;

        try {
            value = globalStorage[self.getHost()].getItem(name);
        }
        catch(e) {
        };

        cb(self.getName(), value);
    };

    self.set = function(name, value) {
        try {
            globalStorage[self.getHost()].setItem(name, value);
        }
        catch(e) {
        };
    };
}

function EvercookieDatabaseStorage() {
    var self = this;

    self.getName = function() { return 'databaseStorage'; };

    self.getDatabase = function() {
        return window.openDatabase("sqlite_evercookie", "", "evercookie", 1024 * 1024);
    };

    self.get = function(name, cb) {
        var value;

        try {
            self.getDatabase().transaction(function(tx) {
                tx.executeSql("SELECT value FROM cache WHERE name=?", [name],
                function(tx, result) {
                    if (result.rows.length >= 1) {
                        value = result.rows.item(0)['value'];
                    }

                    cb(self.getName(), value);
                }, function (tx, err) {
                    cb(self.getName(), undefined);
                })
            });
        }
        catch(e) {
            cb(self.getName(), value);
        };
    };

    self.set = function(name, value) {
        try {
            self.getDatabase().transaction(function(tx) {
                tx.executeSql("CREATE TABLE IF NOT EXISTS cache(" +
                    "id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, " +
                    "name TEXT NOT NULL, " +
                    "value TEXT NOT NULL, " +
                    "UNIQUE (name)" +
                ")", [], function (tx, rs) { }, function (tx, err) { });

                tx.executeSql("INSERT OR REPLACE INTO cache(name, value) VALUES(?, ?)", [name, value],
                    function (tx, rs) { }, function (tx, err) { })
            });
        }
        catch(e) {
        };
    };
}

EvercookieDatabaseStorage.isSupported = function() {
    return !!window.openDatabase;
}

function EvercookieLSO() {
    var self = this;

    self.getName = function() { return 'LSO'; };

    self.swfStore = new SwfStore({
        namespace: 'evercookie',
        swf_url: '/evercookie/storage.swf',
        onready: function() {
        }
    });

    self.movieName = 'evercookie';

    self.get = function(name, cb) {
        var wait = function() {
            if (self.swfStore.ready) {
                var value = self.swfStore.get(name);
                cb(self.getName(), value);
            }
            else {
                setTimeout(wait, 100);
            }
        };

        setTimeout(wait, 100);
    };

    self.set = function(name, value) {
        self.swfStore.set(name, value);
    };
}

EvercookieLSO.isSupported = function() {
    if (window.ActiveXObject) {
        try {
            new ActiveXObject('ShockwaveFlash.ShockwaveFlash');
            return true;
        } catch (e) {
            return false;
        }
    }

    for (var i = 0; i < navigator.plugins.length; i++) {
        var plugin = navigator.plugins[i];
        if (plugin.name.match(/flash/i)) {
            return true;
        }
    }

    return false;
}
