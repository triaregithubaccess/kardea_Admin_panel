import Vue from 'vue'
import Vuex from 'vuex'
import * as actions from './actions'
import * as getters from './getters'

Vue.use(Vuex)

# Initial state
state =
  count: 10


#  Mutations
mutations =
  INCREMENT: (state) -> state.count += 1
  DECREMENT: (state) -> state.count += 2


vuex_store = new Vuex.Store { actions, getters, state, mutations }

`export default vuex_store`