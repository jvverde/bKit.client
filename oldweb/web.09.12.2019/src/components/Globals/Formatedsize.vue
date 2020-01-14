<template>
  <span class="size">{{size}}</span>
</template>

<script>
function niceBytes (x) {
  let units = ['B', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB']
  let n = 0 | x
  let l = 0
  while (n > 1024) {
    n /= 1024
    l++
  }
  return n.toFixed(n >= 10 || l === 0 ? 0 : 1) + ' ' + units[l]
}

export default {
  name: 'formatedsize',
  computed: {
    size () {
      return niceBytes(this.value)
    }
  },
  props: ['value']
}
</script>

<style scoped>
  span.size{
    display: inline-block;
    text-overflow: ellipsis;
    white-space: nowrap;
    padding-left: .2em;
    padding-right: .2em;
  }
</style>
