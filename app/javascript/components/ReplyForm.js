import React from "react";
import PropTypes from "prop-types";

class ReplyForm extends React.Component {
  render () {
    const id = `reply-form-${this.props.pnumber}-${this.props.count}`;
    return (
      <React.Fragment>
        <form
          id={id}
          className="reply-form"
        >
          <div>
            <textarea
              cols="80"
              placeholder="It's important to be kind when replying..."
              rows="3"
            />
            <br />
            <button
              offset={this.props.offset}
              onClick={submitReply}
              pid={this.props.pid}
              type="button"
            >
              Submit Reply
            </button>
          </div>
        </form>
      </React.Fragment>
    );
  }
}

ReplyForm.propTypes = {
  count: PropTypes.number,
  offset: PropTypes.number,
  pid: PropTypes.number,
  pnumber: PropTypes.number,
  text: PropTypes.string,
};
export default ReplyForm
