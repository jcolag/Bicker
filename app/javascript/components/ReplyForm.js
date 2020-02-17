import React from "react";
import PropTypes from "prop-types";

class ReplyForm extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      count: this.props.count,
      offset: this.props.offset,
      pid: this.props.pid,
      pnumber: this.props.pnumber,
      text: this.props.punc,
    };
  }

  render () {
    const id = `reply-form-${this.state.pnumber}-${this.state.count}`;
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
              offset={this.state.offset}
              onClick={submitReply}
              pid={this.state.pid}
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
