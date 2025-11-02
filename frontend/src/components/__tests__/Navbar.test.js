import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import Navbar from '../Navbar.vue'

describe('Navbar.vue', () => {
  it('renders correctly', () => {
    const wrapper = mount(Navbar)
    expect(wrapper.exists()).toBe(true)
  })
})

