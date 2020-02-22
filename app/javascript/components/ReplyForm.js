import React from "react";
import PropTypes from "prop-types";

class ReplyForm extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      callback: this.props.callback,
      count: this.props.count,
      errorMessage: '',
      offset: this.props.offset,
      pid: this.props.pid,
      pnumber: this.props.pnumber,
      text: this.props.punc,
    };
  }

  reportError(message) {
    this.setState({
      errorMessage: message,
    });
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
            <p className="error-message">
              {this.state.errorMessage}
            </p>
            <textarea
              cols="80"
              placeholder="It's important to be kind when replying..."
              rows="3"
            />
            <br />
            <button
              offset={this.state.offset}
              onClick={(e) => submitReply(
                e,
                this.state.callback,
                this.reportError.bind(this)
              )}
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
  callback: PropTypes.func,
  count: PropTypes.number,
  offset: PropTypes.number,
  pid: PropTypes.number,
  pnumber: PropTypes.number,
  text: PropTypes.string,
};
export default ReplyForm
