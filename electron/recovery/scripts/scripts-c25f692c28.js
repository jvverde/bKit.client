"use strict";
angular.module("bkitApp", ["ngRoute", "ngSanitize", "ngMaterial", "ui.router"]).config(["$routeProvider", "$stateProvider", "$locationProvider", "$urlRouterProvider",
	function (e, t, n, $urlRouterProvider) {

	console.log('here');
	t.state("home", {
		name: "home",
		url: "/",
		templateUrl: "views/main.html",
		controller: "MainCtrl",
		controllerAs: "main",
		resolve: {
			computers: ["home.requests", function (e) {
				console.log('on resolve requests')
				return e.loadComputers()
			}]
		}
	}), e.otherwise({
		redirectTo: "/#/"
	});

	$urlRouterProvider.when('', '/#/');
    // You can also use regex for the match parameter

}]), angular.module("bkitApp").controller("MainCtrl", ["$scope", "$filter", "$timeout", "config", "computers", "home.requests", "transform", "fs", function (e, t, n, r, o, i, c, l) {
	function u(e) {
		return console.log("query", b.computers), t("filter")(b.computers, e)
	}

	function a(e) {
		b.selectedComputer = e
	}

	function s(e) {
		e.forEach(function (e, n, r) {
			r[n].name = t("name.display.filter")(e.name), f(r[n].drives)
		})
	}

	function f(e) {
		e.forEach(function (e, n, r) {
			r[n].name = t("name.display.filter")(e.id)
		})
	}

	function d(e) {
		b.selectedComputer = e, b.backups = [], b.selectedBackup = null, b.selectedDrive = null, b.explorer = null
	}

	function p(t) {
		t && (b.selectedDrive = t, console.log("drive", t), b.backups = c.backupsByDate(b.selectedComputer, t), n(function () {
			e.syncronizeSelection(b.backups[0], "id")
		}, 10))
	}

	function h(e, t) {
		b.selectedBackup && b.selectedBackup.id === t.id || (b.selectedBackup = t, m(b.path, t.computer.id, t.drive.id, t.id))
	}

	function m(e, t, n, r) {
		var o;
		"string" == typeof e ? (b.path = e, o = l.resolveFolder(e)) : (b.path = l.resolvePath(e), o = e), !o.opened && 0 === o.folders.length || r ? (b.loading = !0, l.loadData(t || b.selectedComputer.id, n || b.selectedDrive.id, r || b.selectedBackup.id, b.path).then(function (e) {
			b.explorer = e, v(l.resolveFolder(b.path)), b.loading = !1
		})) : v(o)
	}

	function v(e) {
		b.currentFolder = e, b.currentFolder.opened = !0, g(b.explorer), b.currentFolder.selected = !0
	}

	function g(e) {
		e.selected = !1, e.opened && e.folders.forEach(function (e) {
			g(e)
		})
	}

	function k(e, t) {
		return i.buildUrl("/" + t, [b.selectedComputer.id, b.selectedDrive.id, b.selectedBackup.id, b.path])
	}
	var b = this;
	b.computers = o, b.backups = [], b.path = "", b.querySearch = u, b.onSelectBackup = h, b.selectComputer = a, b.processSelection = p, b.reset = d, b.loadContent = m, b.buildUrl = k, s(b.computers)

	console.log('mainCtrl');
}]), angular.module("bkitApp").directive("calendar", ["config", function (e) {
	return {
		templateUrl: "scripts/directives/calendar.tmpl.html",
		restrict: "E",
		scope: !1,
		replace: !0,
		link: function (t, n, r) {
			function o(e, n, o) {
				t.selectedCell = n, t.$eval(r.onCellClick)(e, o)
			}

			function i(e, n) {
				if (e)
					for (var r = 0; r < t.content.length; r++)
						if (t.content[r][n] === e[n]) {
							t.scrollTo(1 - r / t.content.length), o(null, t.content.length - 1 - r, e);
							break
						}
			}
			t.handleCellClick = o, t.syncronizeSelection = i, t.increment = e.calendar.cell.width / 2, t.$watchCollection(r.content, function (n, o) {
				t.content = t.$eval(r.content), t.overflowedElemWidth = t.content.length * e.calendar.cell.width
			})
		}
	}
}]), angular.module("bkitApp").constant("config", {
	calendar: {
		cell: {
			width: 100
		}
	},
	logo: {
		path: "images/logo/",
		name: function (e, t) {
			return t || (t = "png"), e % 32 !== 0 && (e = 512), e + "x" + e + "." + t
		}
	},
	server: {
		url: "http://10.11.0.135:8088"
	}
}), angular.module("bkitApp").directive("day", function () {
	return {
		templateUrl: "scripts/directives/day.tmpl.html",
		restrict: "E",
		link: function (e, t, n) {}
	}
}), angular.module("bkitApp").service("home.requests", ["$http", "$q", "config", function (e, t, n) {
	function r(e, t) {
		return t && Array.isArray(t) && t.forEach(function (t) {
			e += "/" + t
		}), n.server.url + e
	}

	function o(e, t, n) {
		return Object.keys(e).map(function (r) {
			var o = {};
			return o[t] = r, o[n] = e[r], o
		})
	}
	var i = this;
	this.buildUrl = r, this.loadComputers = function () {
		return e.get(r("/computers")).then(function (e) {
			var n = o(e.data, "name", "id"),
				r = [];
			return n.forEach(function (e, t, n) {
				var c = i.loadDrives(e.id).then(function (e) {
					return e = o(e, "id", "backups"), n[t].drives = e, n[t]
				});
				r.push(c)
			}), t.all(r)
		})["catch"](function (e) {
			console.error("exception", e)
		})
	}, this.loadDrives = function (t) {
		return e.get(r("/backups", [t])).then(function (e) {
			return e.data
		}, function (e) {
			console.error("http err", e)
		})["catch"](function (e) {
			console.error("exception", e)
		})
	}, this.getBackup = function (t, n, o, i) {
		return e.get(r("/folder", [t, n, o, i])).then(function (e) {
			return e.data
		}, function (e) {
			console.error("http err", e)
		})["catch"](function (e) {
			console.error("exception", e)
		})
	}, this.restore = function (t, n, o, i) {
		return e.get(r("/bkit", [n, o, i, t])).then(function (e) {
			return e
		}, function (e) {
			console.error("http err", e)
		})["catch"](function (e) {
			console.error("exception", e)
		})
	}, this.view = function (t, n, o, i) {
		return e.get(r("/view", [n, o, i, t])).then(function (e) {
			return e
		}, function (e) {
			console.error("http err", e)
		})["catch"](function (e) {
			console.error("exception", e)
		})
	}, this.download = function (t, n, o, i) {
		return e.get(r("/download", [n, o, i, t])).then(function (e) {
			return e
		}, function (e) {
			console.error("http err", e)
		})["catch"](function (e) {
			console.error("exception", e)
		})
	}
}]), angular.module("bkitApp").service("error.logger", function () {}), angular.module("bkitApp").directive("scrollControl", function () {
	return {
		restrict: "A",
		link: function (e, t, n) {
			t.on("scroll", function (e) {
				console.log("onScroll", this.scrollLeft)
			}), e.scroll = function (e, n) {
				if ("left" === e) t[0].scrollLeft -= n;
				else {
					if ("right" !== e) throw new Error("Unknown direction");
					t[0].scrollLeft += n
				}
			}, e.scrollTo = function (n) {
				var r = t[0].clientWidth,
					o = e.overflowedElemWidth - r;
				t[0].scrollLeft = o * n
			}
		}
	}
}), angular.module("bkitApp").directive("mouseHold", ["$interval", "config", function (e, t) {
	return {
		restrict: "A",
		link: function (t, n, r) {
			var o;
			n.on("mousedown", function (n) {
				t.$eval(r.mouseHold), o = e(function () {
					t.$eval(r.mouseHold)
				}, 100)
			}), n.on("mouseup", function (t) {
				e.cancel(o)
			})
		}
	}
}]), angular.module("bkitApp").service("transform", function () {
	this.backupsByDate = function (e, t) {
		var n = [];
		return t.backups.forEach(function (r) {
			var o = moment(r.substring(5), "YYYY.MM.DD-HH.mm.ss"),
				i = {
					computer: e,
					drive: t,
					time: o,
					id: r
				};
			n.push(i)
		}), n.sort(function (e, t) {
			return e.time.isAfter(t.time) ? -1 : 1
		}), n
	}
}), angular.module("bkitApp").service("fs", ["home.requests", function (e) {
	var t = this,
		n = {
			name: "root",
			parent: null,
			folders: [],
			files: []
		};
	this.loadData = function (r, o, i, c) {
		return e.getBackup(r, o, i, c).then(function (e) {
			var r = n;
			return "" !== c && (r = t.resolveFolder(c)), r.files = e.files, e.folders.forEach(function (e) {
				r.folders.push({
					name: e,
					parent: r,
					folders: [],
					files: []
				})
			}), n
		})
	}, this.resolvePath = function (e) {
		for (var t = "", n = e; null !== n.parent;) t = n.name + "/" + t, n = n.parent;
		return t
	}, this.resolveFolder = function (e) {
		var t = n,
			r = e.split("/");
		return r.forEach(function (e) {
			t.folders.some(function (n) {
				if (n.name === e) return t = n, !0
			})
		}), t
	}
}]), angular.module("bkitApp").filter("name.display.filter", function () {
	var e = [];
	return function (t) {
		if (!t) return "";
		var n = t.indexOf("."),
			r = 0;
		if (n === -1) return t;
		var o = t.substring(0, n),
			i = e.some(function (e, t) {
				return r = t, e.name === o
			});
		return i ? o += " (" + ++e[r].count + ")" : e.push({
			name: o,
			count: 1
		}), o
	}
}), angular.module("bkitApp").filter("bakDisplay", function () {
	return function (e) {
		return e
	}
});
