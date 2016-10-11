proxyquire = require('proxyquireify')(require)

Trade = () ->
Trade.buy = (quote) ->
  Promise.resolve({amount: quote.baseAmount})

stubs = {
  './trade' : Trade
}

PaymentMethod    = proxyquire('../../src/exchange/payment-method', stubs)
api = undefined

beforeEach ->
  api = {mock: "api"}

  JasminePromiseMatchers.install()

afterEach ->
  JasminePromiseMatchers.uninstall()

describe "Payment method", ->
  describe "class", ->
    describe "constructor", ->
      it "should keep a reference to the api", ->
        b = new PaymentMethod(api)
        expect(b._api).toEqual(api)

  describe "instance", ->
    p = undefined
    delegate = undefined

    beforeEach ->
      delegate =
        save: () -> Promise.resolve()
        trades: []

      quote =
        expiresAt: new Date(new Date().getTime() + 100000)
        baseAmount: -1000
        baseCurrency: 'EUR'
        delegate: delegate
        api: {}
        debug: false

      p = new PaymentMethod(api, quote, Trade)

    it "should have getters", ->
      p._inMedium = 'card'
      expect(p.inMedium).toBe('card')

    describe 'buy()', ->
      it 'should use Trade.buy', ->
        spyOn(Trade, "buy").and.callThrough()

        p.buy('card')

        expect(Trade.buy).toHaveBeenCalled()

      it 'should return the trade', (done) ->
        checks = (res) ->
          expect(res).toEqual({amount: -1000, debug: false})

        p.buy('card').then(checks).then(done)

      it "should save", (done) ->
        spyOn(delegate, "save").and.callThrough()

        checks = () ->
          expect(delegate.save).toHaveBeenCalled()

        p.buy('card').then(checks).then(done)