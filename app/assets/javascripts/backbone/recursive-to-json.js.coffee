Backbone.Model.prototype.toJSON = ->
  if (this._isSerializing)
    return this.id || this.cid

  this._isSerializing = true
  json = _.clone(this.attributes)
  _.each json, (value, name)->
    _.isFunction((value || "").toJSON) && (json[name] = value.toJSON())

  this._isSerializing = false
  return json

