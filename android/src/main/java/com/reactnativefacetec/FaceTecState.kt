package com.reactnativefacetec

class FaceTecState() {
  var status: FaceTecStatus? = null
  var message: String? = null
  var load: String? = null

  constructor (status: FaceTecStatus) : this() {
    this.status = status
  }

  constructor (status: FaceTecStatus, message: String) : this() {
    this.status = status
    this.message = message
  }
}
