import { Controller } from "stimulus"

export default class extends Controller {



  select(event) {
    const { start, end, roomId } = event.target.dataset
    this.reserve(start, end, roomId)
  }

  reserve(start, end, roomId) {
    // Rails.ajax({
    //   url: "/appointments",
    //   type: "post",
    //   data: { starts_at: start, ends_at: end, room_id: roomId }
    // })
  }
}
