// Generated by CoffeeScript 1.10.0
(function(window, $, templates) {
  'use strict';
  var activateSidebar, mainContainer, toggleSidebar;
  mainContainer = $('#main-container');
  window.mainContainer = mainContainer;
  activateSidebar = function() {
    var sidebar;
    sidebar = $('#views-sidebar');
    sidebar.addClass('with-sidebar-handle');
    return sidebar.prepend(templates.sidebarRetract);
  };
  toggleSidebar = function() {
    ($('#views-container')).toggleClass('sidebar-hidden');
    ($(window)).trigger('views-sidebar-toggled');
  };
  window.loadContent = function(url) {
    var res;
    res = $.get(url);
    res.done(function(data) {
      mainContainer.html(data);
      (mainContainer.find('a')).first().focus();
      activateSidebar();
      window.triggerTabChange();
    });
    res.fail(function() {
      return alert(templates.alertLoadError);
    });
    return res;
  };
  mainContainer.on('click', '.views-tabs-tab-link', function(e) {
    var elem, res, url;
    e.preventDefault();
    e.stopPropagation();
    elem = $(this);
    url = elem.attr('href');
    res = loadContent(url);
    return res.done(function() {
      window.history.pushState(null, null, url);
      window.triggerTabChange();
    });
  });
  window.onTabChange = function(func) {
    window.mainContainer.on('filemanager:tabchanged', func);
  };
  window.triggerTabChange = function() {
    window.mainContainer.trigger('filemanager:tabchanged');
  };
  window.changeLocation = function(url) {
    window.history.pushState(null, null, url);
  };
  $(window).on('popstate', function(e) {
    loadContent(window.location);
  });
  activateSidebar();
  mainContainer.on('click', '.views-sidebar-retract', toggleSidebar);
  ($(window)).on('views-sidebar-toggle', toggleSidebar);
})(this, this.jQuery, this.templates);
