import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import UploadCard from '../UploadCard.vue'

describe('UploadCard.vue', () => {
  it('renders correctly', () => {
    const wrapper = mount(UploadCard)
    expect(wrapper.exists()).toBe(true)
  })

  it('has upload form elements', () => {
    const wrapper = mount(UploadCard)
    expect(wrapper.find('form').exists()).toBe(true)
  })
})

